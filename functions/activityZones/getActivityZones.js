const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const organizationId = req.query.organizationId;

      if (!organizationId) {
        return res.status(400).send({ error: "organizationId required" });
      }

      // Fetch the organization document to get its activityZoneIds array
      const orgDoc = await db.collection("organization").doc(organizationId).get();
      if (!orgDoc.exists) {
        return res.status(404).send({ error: "Organization not found" });
      }

      const activityZoneIds = orgDoc.data().activityZoneIds || [];
      if (activityZoneIds.length === 0) {
        return res.status(200).send([]);
      }

      // Fetch all activity zone documents by ID in parallel
      const zoneDocs = await Promise.all(
        activityZoneIds.map((zoneId) =>
          db.collection("activityZone").doc(zoneId).get()
        )
      );

      const existingZones = zoneDocs.filter((doc) => doc.exists);

      // Collect unique addressIds to fetch in batch
      const addressIds = [
        ...new Set(existingZones.map((doc) => doc.data().addressId)),
      ];

      // Fetch all addresses in parallel
      const addressMap = {};
      await Promise.all(
        addressIds.map(async (addressId) => {
          const addrDoc = await db.collection("address").doc(addressId).get();
          if (addrDoc.exists) {
            addressMap[addressId] = { id: addrDoc.id, ...addrDoc.data() };
          }
        })
      );

      const result = existingZones.map((doc) => {
        const data = doc.data();
        return {
          id: doc.id,
          name: data.name,
          addressId: data.addressId,
          range: data.range,
          organizationId: organizationId,
          address: addressMap[data.addressId] || null,
        };
      });

      return res.status(200).send(result);
    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};
