// functions/users/updateUserProfile.js
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
    //   const { name, img } = req.body;
      const { name } = req.body;

      const updateData = {};
      if (name !== undefined) updateData.name = name;
    //   if (img !== undefined) updateData.img = img;

      await db.collection("user").doc(uid).update(updateData);

      return res.status(200).send({ status: "success" });
    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};