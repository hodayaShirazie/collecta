// const admin = require("firebase-admin");
// const corsHandler = require("../utils/cors");
// const verifyFirebaseToken = require("../utils/verifyToken");

// const db = admin.firestore();


// module.exports = async (req, res) => {
//   corsHandler(req, res, async () => {
//     const firebaseUser = await verifyFirebaseToken(req, res);
//     if (!firebaseUser) return;

//     try {
//       const {
//         donationId,
//         contactName,
//         contactPhone,
//         products,
//         pickupTimes,
//         businessAddress,
//         businessName,
//         businessPhone,
//         businessId,
//         donatedItems
//       } = req.body;

//       if (!donationId) {
//         return res.status(400).send({ error: "Missing donationId" });
//       }

//       // 🔹 1. עדכון כתובת
//       if (businessAddress?.id) {
//         await db.collection("address").doc(businessAddress.id).update({
//           name: businessAddress.name,
//           lat: Number(businessAddress.lat),
//           lng: Number(businessAddress.lng),
//         });
//       }

//       // 🔹 2. עדכון מסמך Donation
//       await db.collection("donation").doc(donationId).update({
//         contactName,
//         contactPhone,
//         businessName,
//         businessPhone,
//         businessId,
//         pickupTimes,
//         products: products.map(p => p.id), // שמירת IDs בלבד
//       });

//       // 🔹 3. עדכון פריטים אם צריך
//       for (const item of donatedItems || []) {
//         if (item["id"] && item["description"]) {
//           await db.collection("product").doc(item["id"]).update({
//             quantity: Number(item["quantity"]),
//             description: item["description"],
//           });
//         }
//       }

//       return res.status(200).send({ status: "success" });

//     } catch (e) {
//       return res.status(500).send({ error: e.message });
//     }
//   });
// };


const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const {
        donationId,
        contactName,
        contactPhone,
        products,
        pickupTimes,
        businessAddress,
        businessName,
        businessPhone,
        businessId,
        donatedItems
      } = req.body;

      if (!donationId) {
        return res.status(400).send({ error: "Missing donationId" });
      }

      // 🔹 1. עדכון כתובת
      if (businessAddress?.id) {
        await db.collection("address").doc(businessAddress.id).update({
          name: businessAddress.name,
          lat: Number(businessAddress.lat),
          lng: Number(businessAddress.lng),
        });
      }

      // 🔹 2. עדכון מסמך Donation
      await db.collection("donation").doc(donationId).update({
        contactName,
        contactPhone,
        businessName,
        businessPhone,
        businessId,
        pickupTimes,
        products: donatedItems.map(item => item.id), // שמירת IDs בלבד
      });

      // 🔹 3. עדכון פריטים
      for (const item of donatedItems || []) {
        if (!item["id"]) continue;

        const productRef = db.collection("product").doc(item["id"]);
        const productTypeRef = db.collection("productType").doc(item["productType"]);

        // אם זה "אחר" נעדכן את ה-description בטבלת ProductType
        if (item["name"] === "אחר" && item["description"]) {
          await productTypeRef.update({
            description: item["description"]
          });
        }

        // עדכון הכמות וה-ID בטבלת Product
        await productRef.update({
          quantity: Number(item["quantity"]),
          productType: item["productType"],
          description: item["description"] || ""
        });
      }

      return res.status(200).send({ status: "success" });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};