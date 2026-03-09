// const admin = require("firebase-admin");
// const corsHandler = require("../utils/cors");
// const verifyFirebaseToken = require("../utils/verifyToken");

// const db = admin.firestore();

// module.exports = async (req, res) => {

//   corsHandler(req, res, async () => {

//     const firebaseUser = await verifyFirebaseToken(req, res);
//     if (!firebaseUser) return;

//     try {

//       const uid = firebaseUser.uid;

//       const { phone, area, destinations } = req.body;

//       await db.collection("driver").doc(uid).update({
//         phone,
//         area
//       });

//       for (const d of destinations) {

//         if (!d.address) continue;

//         const addressRef = db.collection("addresses").doc();

//         await addressRef.set({
//           name: d.address,
//           lat: d.lat,
//           lng: d.lng
//         });

//         await db.collection("destinations").add({
//           name: d.name,
//           day: d.day,
//           organization_id: "xFKMWqidL2uZ5wnksdYX",
//           address_id: addressRef.id,
//           driver_id: uid
//         });
//       }

//       return res.status(200).send({ status: "success" });

//     } catch (e) {

//       return res.status(500).send({ error: e.message });
//     }
//   });
// };

const admin = require("firebase-admin");
const verifyFirebaseToken = require("../utils/verifyToken");
const corsHandler = require("../utils/cors");

const db = admin.firestore();

module.exports = async (req, res) => {

  corsHandler(req, res, async () => {

    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {

      const uid = firebaseUser.uid;

      const { phone, area, destinations } = req.body;

      const updateData = {};

      if (phone !== undefined) updateData.phone = phone;
      if (area !== undefined) updateData.area = area;
      if (destinations !== undefined) updateData.destinations = destinations;

      await db.collection("driver").doc(uid).update(updateData);

      return res.status(200).send({
        status: "success"
      });

    } catch (e) {

      return res.status(500).send({
        error: e.message
      });

    }

  });

};