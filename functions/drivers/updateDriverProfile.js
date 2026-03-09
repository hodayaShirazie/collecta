// functions/drivers/updateDriverProfile.js
const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {

    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {

      const uid = firebaseUser.uid;

      const { phone, area } = req.body;

      const updateData = {};

      if (phone !== undefined) updateData.phone = phone;
      if (area !== undefined) updateData.area = area;

      await db.collection("driver").doc(uid).update(updateData);

      return res.status(200).send({ status: "success" });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }

  });
};