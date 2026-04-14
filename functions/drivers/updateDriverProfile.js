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

      const { phone, area } = req.body;

      if (
        (phone !== undefined && !isValidString(phone)) ||
        (area !== undefined && !isValidString(area))
      ) {
        return res.status(400).send({ error: "Invalid input parameters" });
      }

      const updateData = {};

      if (phone !== undefined && phone !== '') updateData.phone = phone;
      if (area !== undefined && area !== '') updateData.area = area;

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