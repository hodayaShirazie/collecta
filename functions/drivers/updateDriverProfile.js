// functions/drivers/updateDriverProfile.js
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

      await db.collection("driver").doc(uid).update(updateData);

      return res.status(200).send({ status: "success" });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }

  });
};
