// functions/drivers/updateDriverProfile.js
const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
// const resolveUid = require("../utils/resolveUid");
const verifyFirebaseToken = require("../utils/verifyToken");
const { isValidString } = require("../utils/validate");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {

    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {

      const uid = firebaseUser.uid;

      const { phone, areas } = req.body;

      if (phone !== undefined && !isValidString(phone)) {
        return res.status(400).send({ error: "Invalid input parameters" });
      }

      if (areas !== undefined && !Array.isArray(areas)) {
        return res.status(400).send({ error: "areas must be an array" });
      }

      const updateData = {};

      if (phone !== undefined && phone !== '') updateData.phone = phone;
      if (areas !== undefined) updateData.areas = areas;

      if (Object.keys(updateData).length === 0) {
        return res.status(400).send({ error: "No fields to update" });
      }

      if (areas !== undefined) {
        // Validate that none of the new zones are already assigned to another driver
        const zoneChecks = await Promise.all(
          areas.map((zoneId) => db.collection("activityZone").doc(zoneId).get())
        );
        for (const zoneDoc of zoneChecks) {
          if (!zoneDoc.exists) continue;
          const existingDriverId = zoneDoc.data().driverId ?? "";
          if (existingDriverId !== "" && existingDriverId !== uid) {
            return res.status(409).send({ error: `אזור ${zoneDoc.data().name} כבר משויך לנהג אחר` });
          }
        }

        // Get current driver areas to find what changed
        const driverDoc = await db.collection("driver").doc(uid).get();
        const oldAreas = driverDoc.exists ? (driverDoc.data().areas ?? []) : [];

        const removedZones = oldAreas.filter((id) => !areas.includes(id));
        const addedZones = areas.filter((id) => !oldAreas.includes(id));

        const batch = db.batch();

        for (const zoneId of removedZones) {
          batch.update(db.collection("activityZone").doc(zoneId), { driverId: "" });
        }
        for (const zoneId of addedZones) {
          batch.update(db.collection("activityZone").doc(zoneId), { driverId: uid });
        }

        batch.update(db.collection("driver").doc(uid), updateData);
        await batch.commit();
      } else {
        await db.collection("driver").doc(uid).update(updateData);
      }

      return res.status(200).send({ status: "success" });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }

  });
};