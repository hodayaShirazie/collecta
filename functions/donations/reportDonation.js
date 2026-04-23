const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const { isValidString } = require("../utils/validate");
const db = admin.firestore();

// Haversine formula – מחזיר מרחק בין שתי נקודות במטרים
function getDistanceMeters(lat1, lng1, lat2, lng2) {
  const R = 6371000;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLng / 2) * Math.sin(dLng / 2);
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// מחזיר driver_id של הנהג שהאזור שלו מכסה את הכתובת, או "" אם לא נמצא
async function resolveDriverId(businessAddressId, organizationId) {
  // 1. שלוף את הלט/לנג של כתובת התרומה
  const addrDoc = await db.collection("address").doc(businessAddressId).get();
  if (!addrDoc.exists) return "";

  const { lat: donLat, lng: donLng } = addrDoc.data();

  // 2. שלוף את אזורי הפעילות של הארגון
  const orgDoc = await db.collection("organization").doc(organizationId).get();
  if (!orgDoc.exists) return "";

  const activityZoneIds = orgDoc.data().activityZoneIds || [];
  if (activityZoneIds.length === 0) return "";

  // 3. שלוף את כל מסמכי האזורים
  const zoneDocs = await Promise.all(
    activityZoneIds.map((id) => db.collection("activityZone").doc(id).get())
  );
  const existingZones = zoneDocs.filter((d) => d.exists);

  // 4. שלוף את הכתובות של האזורים (ללא כפילויות)
  const uniqueAddressIds = [...new Set(existingZones.map((d) => d.data().addressId))];
  const addressMap = {};
  await Promise.all(
    uniqueAddressIds.map(async (aid) => {
      const doc = await db.collection("address").doc(aid).get();
      if (doc.exists) addressMap[aid] = doc.data();
    })
  );

  // 5. מצא אזור ראשון שהכתובת של התרומה בתוך הטווח שלו
  let matchingZoneId = null;
  for (const zoneDoc of existingZones) {
    const zone = zoneDoc.data();
    const zoneAddr = addressMap[zone.addressId];
    if (!zoneAddr) continue;

    const dist = getDistanceMeters(donLat, donLng, zoneAddr.lat, zoneAddr.lng);
    if (dist <= zone.range) {
      matchingZoneId = zoneDoc.id;
      break;
    }
  }

  if (!matchingZoneId) return "";

  // 6. מצא נהג שהאזור הזה ברשימת האזורים שלו
  const driverSnap = await db
    .collection("driver")
    .where("activityZone", "array-contains", matchingZoneId)
    .limit(1)
    .get();

  if (driverSnap.empty) return "";
  return driverSnap.docs[0].data().id || "";
}

// Function to report a donation
module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const {
        businessName,
        businessAddress,
        businessPhone,
        crn,
        contactName,
        contactPhone,
        products,
        pickupTimes,
        organization_id,
        canceling_reason = "",
        recipe = ""
      } = req.body;

      if (
        !businessName ||
        !businessAddress ||
        !businessPhone ||
        !contactName ||
        !contactPhone ||
        !products ||
        !pickupTimes ||
        !organization_id
      ) {
        return res.status(400).send({ error: "Missing fields" });
      }

      if (
        !isValidString(businessName) ||
        !isValidString(businessAddress) ||
        !isValidString(businessPhone) ||
        !isValidString(contactName) ||
        !isValidString(contactPhone) ||
        !isValidString(organization_id)
      ) {
        return res.status(400).send({ error: "Invalid input parameters" });
      }

      // שיוך אוטומטי של נהג לפי אזורי פעילות
      let driver_id = "";
      try {
        driver_id = await resolveDriverId(businessAddress, organization_id);
      } catch (assignErr) {
        // שיוך נהג הוא לא-קריטי – ממשיך ללא שיוך
        console.warn("⚠️ Auto driver assignment failed:", assignErr.message);
      }

      const donationData = {
        donor_id: firebaseUser.uid,
        businessName,
        businessAddress,
        businessPhone,
        crn,
        contactName,
        contactPhone,
        products,
        pickupTimes,
        driver_id,
        canceling_reason,
        recipe,
        organization_id,
        status: "pending",
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      };

      const docRef = await db.collection("donation").add(donationData);

      return res.status(200).send({
        status: "success",
        donationId: docRef.id
      });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};
