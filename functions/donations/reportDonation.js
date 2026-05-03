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

// עובר נהג נהג ובודק אם כתובת התרומה נמצאת בטווח של אחד מאזורי הפעילות שלו.
// מחזיר את ה-id של הנהג הראשון שנמצאה התאמה, או "" אם אין.
async function resolveDriverId(businessAddressId, organizationId) {
  // 1. שלוף את הלט/לנג של כתובת התרומה
  const addrDoc = await db.collection("address").doc(businessAddressId).get();
  if (!addrDoc.exists) {
    console.log("🔍 resolveDriverId: address doc not found:", businessAddressId);
    return "";
  }
  const { lat: donLat, lng: donLng } = addrDoc.data();
  console.log(`🔍 resolveDriverId: donation lat=${donLat}, lng=${donLng}`);

  // 2. שלוף את כל המשתמשים של הארגון
  const usersSnap = await db.collection("user")
    .where("organization_id", "==", organizationId)
    .get();
  if (usersSnap.empty) {
    console.log("🔍 resolveDriverId: no users for org:", organizationId);
    return "";
  }
  const uids = usersSnap.docs.map((d) => d.data().uid).filter(Boolean);
  if (uids.length === 0) return "";

  // 3. שלוף את כל הנהגים בקבוצות של 30 (מגבלת Firestore)
  const driverDocs = [];
  for (let i = 0; i < uids.length; i += 30) {
    const chunk = uids.slice(i, i + 30);
    const snap = await db.collection("driver").where("id", "in", chunk).get();
    driverDocs.push(...snap.docs);
  }
  if (driverDocs.length === 0) {
    console.log("🔍 resolveDriverId: no drivers found for org:", organizationId);
    return "";
  }

  // 4. אסוף את כל מזהי האזורים מכל הנהגים
  const driverZoneMap = {};
  const allZoneIds = new Set();
  for (const driverDoc of driverDocs) {
    const data = driverDoc.data();
    const zoneIds = data.activityZone || [];
    driverZoneMap[data.id] = zoneIds;
    zoneIds.forEach((id) => allZoneIds.add(id));
  }
  if (allZoneIds.size === 0) {
    console.log("🔍 resolveDriverId: no activity zones assigned to any driver");
    return "";
  }

  // 5. טען את כל מסמכי האזורים בבת אחת
  const zoneDocsArr = await Promise.all(
    [...allZoneIds].map((id) => db.collection("activityZone").doc(id).get())
  );
  const zonesMap = {};
  const zoneAddressIds = new Set();
  for (const zoneDoc of zoneDocsArr) {
    if (zoneDoc.exists) {
      zonesMap[zoneDoc.id] = zoneDoc.data();
      zoneAddressIds.add(zoneDoc.data().addressId);
    }
  }

  // 6. טען את כל כתובות מרכזי האזורים בבת אחת
  const zoneAddrDocsArr = await Promise.all(
    [...zoneAddressIds].map((id) => db.collection("address").doc(id).get())
  );
  const zoneAddressMap = {};
  for (const zAddrDoc of zoneAddrDocsArr) {
    if (zAddrDoc.exists) zoneAddressMap[zAddrDoc.id] = zAddrDoc.data();
  }

  // 7. עבור נהג נהג ובדוק אם כתובת התרומה בטווח של אחד מאזוריו
  for (const driverDoc of driverDocs) {
    const driverData = driverDoc.data();
    const zoneIds = driverZoneMap[driverData.id] || [];
    for (const zoneId of zoneIds) {
      const zone = zonesMap[zoneId];
      if (!zone) continue;
      const zoneAddr = zoneAddressMap[zone.addressId];
      if (!zoneAddr) continue;
      const dist = getDistanceMeters(donLat, donLng, zoneAddr.lat, zoneAddr.lng);
      console.log(`🔍 Driver ${driverData.id} | zone "${zone.name}" | dist=${Math.round(dist)}m | range=${zone.range}m`);
      if (dist <= zone.range) {
        console.log(`✅ resolveDriverId: matched driver ${driverData.id} via zone "${zone.name}"`);
        return driverData.id;
      }
    }
  }

  console.log("🔍 resolveDriverId: no matching driver zone found");
  return "";
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

      if (driver_id) {
        await db.collection("driver").doc(driver_id).update({
          stops: admin.firestore.FieldValue.arrayUnion(docRef.id),
        });
      }

      return res.status(200).send({
        status: "success",
        donationId: docRef.id
      });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};
