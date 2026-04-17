const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const resolveUid = require("../utils/resolveUid");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const uid = await resolveUid(req, res);
    if (!uid) return;

    try {

      /// 1️⃣ user
      const userSnap = await db.collection("user").doc(uid).get();
      if (!userSnap.exists) {
        return res.status(404).send({ error: "User not found" });
      }

      /// 2️⃣ driver
      const driverSnap = await db.collection("driver").doc(uid).get();
      if (!driverSnap.exists) {
        return res.status(404).send({ error: "Driver not found" });
      }

      const driverData = driverSnap.data();

      const destinationIds = driverData.destination || [];

      /// 3️⃣ bring destinations
      const destinations = [];

      for (const destId of destinationIds) {

        const destSnap = await db.collection("destination").doc(destId).get();
        if (!destSnap.exists) continue;

        const destData = destSnap.data();

        /// 4️⃣ bring address
        const addressId = destSnap.id;

        const addressSnap = await db.collection("address").doc(addressId).get();

        let addressData = null;

        if (addressSnap.exists) {
          addressData = {
            id: addressSnap.id,
            ...addressSnap.data(),
          };
        }

        destinations.push({
          id: destSnap.id,
          ...destData,
          address: addressData,
        });
      }

      const normalize = (ts) =>
        ts?.toDate ? ts.toDate().toISOString() : ts;

      return res.status(200).send({
        user: {
          uid,
          ...userSnap.data(),
          created_at: normalize(userSnap.data().created_at),
          last_login: normalize(userSnap.data().last_login),
        },

        role: driverData,

        destinations: destinations,
      });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};