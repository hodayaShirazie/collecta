const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const db = admin.firestore();


// TODO Add verification to check the path of the organization and only allow users with the right role to access it
module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    try {
      const snapshot = await db.collection("organization").get();
      const organizations = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      res.status(200).json(organizations);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

};