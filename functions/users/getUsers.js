const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const db = admin.firestore();


module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const user = await verifyFirebaseToken(req, res);
    if (!user) return;

    try {
      const snapshot = await db.collection("user").get();
      const users = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      res.status(200).json(users);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });
};