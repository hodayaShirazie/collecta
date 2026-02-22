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

      const {
        businessName,
        businessPhone,
        businessAddress_id,
        contactName,
        contactPhone,
        crn,
      } = req.body;

      await db.collection("donor").doc(uid).update({
        businessName,
        businessPhone,
        businessAddress_id,
        contactName,
        contactPhone,
        crn,
      });

      return res.status(200).send({ status: "success" });
    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};

