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

      const adminDoc = await db.collection("admin").doc(uid).get();
      if (!adminDoc.exists) {
        return res.status(403).json({ error: "Not an admin" });
      }

      const userDoc = await db.collection("user").doc(uid).get();
      if (!userDoc.exists) {
        return res.status(404).json({ error: "User profile not found" });
      }

      const organizationId = userDoc.data().organization_id;
      if (!organizationId) {
        return res.status(404).json({ error: "No organization assigned" });
      }

      return res.status(200).json({
        organizationId,
        role: adminDoc.data().role,
      });
    } catch (e) {
      return res.status(500).json({ error: e.message });
    }
  });
};
