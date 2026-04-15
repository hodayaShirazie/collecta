const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const { isValidString } = require("../utils/validate");
const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const { name, addressId, range, organizationId } = req.body;

      if (!name || !addressId || range === undefined || !organizationId) {
        return res.status(400).send({ error: "Missing fields" });
      }

      if (!isValidString(name) || !isValidString(addressId) || !isValidString(organizationId)) {
        return res.status(400).send({ error: "Invalid input parameters" });
      }

      if (typeof range !== "number" || range <= 0) {
        return res.status(400).send({ error: "Invalid range value" });
      }

      const zoneData = {
        name,
        addressId,
        range,
        organizationId,
      };

      const docRef = await db.collection("activityZone").add(zoneData);

      return res.status(200).send({
        status: "success",
        activityZoneId: docRef.id,
      });
    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};
