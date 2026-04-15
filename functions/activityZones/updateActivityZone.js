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
      const { id, name, addressId, range } = req.body;

      if (!id) {
        return res.status(400).send({ error: "activityZone id required" });
      }

      if (!isValidString(id)) {
        return res.status(400).send({ error: "Invalid input parameters" });
      }

      const updateData = {};

      if (name !== undefined) {
        if (!isValidString(name)) {
          return res.status(400).send({ error: "Invalid name" });
        }
        updateData.name = name;
      }

      if (addressId !== undefined) {
        if (!isValidString(addressId)) {
          return res.status(400).send({ error: "Invalid addressId" });
        }
        updateData.addressId = addressId;
      }

      if (range !== undefined) {
        if (typeof range !== "number" || range <= 0) {
          return res.status(400).send({ error: "Invalid range value" });
        }
        updateData.range = range;
      }

      await db.collection("activityZone").doc(id).update(updateData);

      return res.status(200).send({ status: "success" });
    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};
