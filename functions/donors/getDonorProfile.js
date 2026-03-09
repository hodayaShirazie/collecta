// functions/users/getMyProfile.js
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

      // 1. קח את היוזר
      const userSnap = await db.collection("user").doc(uid).get();
      if (!userSnap.exists) return res.status(404).send({ error: "User not found" });

      // 2. קח את התורם
      const donorSnap = await db.collection("donor").doc(uid).get();
      if (!donorSnap.exists) return res.status(404).send({ error: "Donor not found" });

      const donorData = donorSnap.data();
      const addressId = donorData.businessAddress_id; // מזהה הכתובת

      // 3. קח את כתובת העסק לפי businessAddress_id
      let addressData = null;
      if (addressId) {
        const addressSnap = await db.collection("address").doc(addressId).get();
        if (addressSnap.exists) {
          addressData = { id: addressSnap.id, ...addressSnap.data() };
        }
      }

      const normalize = (ts) => ts?.toDate ? ts.toDate().toISOString() : ts;

      return res.status(200).send({
        user: {
          uid,
          ...userSnap.data(),
          created_at: normalize(userSnap.data().created_at),
          last_login: normalize(userSnap.data().last_login),
        },
        role: donorData,
        address: addressData,
      });
    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};