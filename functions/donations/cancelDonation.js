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
      const { donationId } = req.body;

      if (!donationId) {
        return res.status(400).send({ error: "Missing donationId" });
      }

      if (!isValidString(donationId)) {
        return res.status(400).send({ error: "Invalid input parameters" });
      }

      await db.collection("donation").doc(donationId).update({
        status: "cancelled",
      });

      return res.status(200).send({
        status: "success",
      });

    } catch (e) {
      return res.status(500).send({
        error: e.message,
      });
    }
  });
};