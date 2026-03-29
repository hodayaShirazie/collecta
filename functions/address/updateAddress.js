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

      const uid = firebaseUser.uid;
      const { id, name, lat, lng } = req.body;

      if (!id) {
        return res.status(400).send({ error: "address id required" });
      }

      if (!isValidString(id) || (name !== undefined && !isValidString(name))) {
        return res.status(400).send({ error: "Invalid input parameters" });
      }

      const updateData = {};

      if (name !== undefined) updateData.name = name;
      if (lat !== undefined) updateData.lat = lat;
      if (lng !== undefined) updateData.lng = lng;

      await db.collection("address").doc(id).update(updateData);

      return res.status(200).send({ status: "success" });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }

  });
};