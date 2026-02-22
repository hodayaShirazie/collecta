const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const { role } = req.query;

      if (!role) {
        return res.status(400).send({ error: "Missing role" });
      }

      const uid = firebaseUser.uid;

      const userSnap = await db.collection("user").doc(uid).get();
      if (!userSnap.exists) {
        return res.status(404).send({ error: "User not found" });
      }

      const roleSnap = await db.collection(role).doc(uid).get();
      if (!roleSnap.exists) {
        return res.status(404).send({ error: "Role not found" });
      }

      const userData = userSnap.data();
      const roleData = roleSnap.data();

      const normalize = (ts) =>
        ts?.toDate ? ts.toDate().toISOString() : ts;

      return res.status(200).send({
        user: {
          uid: uid,
          ...userData,
          created_at: normalize(userData.created_at),
          last_login: normalize(userData.last_login),
        },
        role: {
          id: roleSnap.id,
          ...roleData,
          created_at: normalize(roleData.created_at),
          last_login: normalize(roleData.last_login),
        },
      });
    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};