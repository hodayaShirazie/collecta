/**
 * One-time migration script:
 * - Reads all activityZone documents that have an organizationId field
 * - Adds each zone's ID to the matching organization's activityZoneIds array
 * - Removes the organizationId field from each activityZone document
 *
 * Run once from the functions directory:
 *   node scripts/migrateActivityZones.js
 */

const admin = require("firebase-admin");
const serviceAccount = require("../serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function migrate() {
  console.log("Starting migration...");

  const zonesSnap = await db.collection("activityZone").get();

  if (zonesSnap.empty) {
    console.log("No activityZone documents found. Nothing to migrate.");
    return;
  }

  // Group zone IDs by organizationId
  const orgToZones = {};
  for (const doc of zonesSnap.docs) {
    const data = doc.data();
    const orgId = data.organizationId;
    if (!orgId) {
      console.log(`  Skipping zone ${doc.id} — no organizationId field.`);
      continue;
    }
    if (!orgToZones[orgId]) orgToZones[orgId] = [];
    orgToZones[orgId].push(doc.id);
  }

  const orgIds = Object.keys(orgToZones);
  if (orgIds.length === 0) {
    console.log("No zones with organizationId found. Nothing to migrate.");
    return;
  }

  // Use batched writes (max 500 ops per batch)
  let batch = db.batch();
  let opCount = 0;

  const commitIfNeeded = async () => {
    if (opCount >= 490) {
      await batch.commit();
      console.log("  Committed intermediate batch.");
      batch = db.batch();
      opCount = 0;
    }
  };

  // 1. Update each organization — set activityZoneIds array
  for (const [orgId, zoneIds] of Object.entries(orgToZones)) {
    console.log(`  Org ${orgId}: adding zones [${zoneIds.join(", ")}]`);
    const orgRef = db.collection("organization").doc(orgId);
    batch.update(orgRef, {
      activityZoneIds: admin.firestore.FieldValue.arrayUnion(...zoneIds),
    });
    opCount++;
    await commitIfNeeded();
  }

  // 2. Remove organizationId from each activityZone document
  for (const doc of zonesSnap.docs) {
    if (!doc.data().organizationId) continue;
    console.log(`  Removing organizationId from zone ${doc.id}`);
    batch.update(doc.ref, {
      organizationId: admin.firestore.FieldValue.delete(),
    });
    opCount++;
    await commitIfNeeded();
  }

  await batch.commit();
  console.log("Migration complete!");
}

migrate().catch((err) => {
  console.error("Migration failed:", err);
  process.exit(1);
});
