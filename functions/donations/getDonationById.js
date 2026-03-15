// // functions/donations/getDonationById.js
// const admin = require("firebase-admin");
// const corsHandler = require("../utils/cors");
// const verifyFirebaseToken = require("../utils/verifyToken");

// const db = admin.firestore();

// module.exports = async (req, res) => {
//   corsHandler(req, res, async () => {
//     try {
//       // 1. בדיקה של Firebase Token
//     //   const firebaseUser = await verifyFirebaseToken(req, res);
//     //   if (!firebaseUser) return;

//       const donationId = req.query.donationId;
//       if (!donationId) return res.status(400).send({ error: "Missing donation ID" });

//       // 2. משוך את התרומה
//       const donationSnap = await db.collection("donation").doc(donationId).get();
//       if (!donationSnap.exists) return res.status(404).send({ error: "Donation not found" });

//       const donationData = donationSnap.data();

//       // Normalize timestamps
//       const normalize = (ts) => ts?.toDate ? ts.toDate().toISOString() : ts;

//       // 3. משוך את היוזר של התורם
//       let userData = null;
//       if (donationData.donor_id) {
//         const userSnap = await db.collection("user").doc(donationData.donor_id).get();
//         if (userSnap.exists) {
//           const u = userSnap.data();
//           userData = {
//             uid: userSnap.id,
//             name: u.name,
//             mail: u.mail,
//             img: u.img,
//             created_at: normalize(u.created_at),
//             last_login: normalize(u.last_login),
//             organization_id: u.organization_id,
//           };
//         }
//       }

//       // 4. משוך את התורם
//       let donorData = null;
//       if (donationData.donor_id) {
//         const donorSnap = await db.collection("donor").doc(donationData.donor_id).get();
//         if (donorSnap.exists) donorData = { id: donorSnap.id, ...donorSnap.data() };
//       }

//       // 5. משוך כתובת לפי businessAddress (מהתרומה)
//       let addressData = null;
//       if (donationData.businessAddress) {
//         const addressSnap = await db.collection("address").doc(donationData.businessAddress).get();
//         if (addressSnap.exists) addressData = { id: addressSnap.id, ...addressSnap.data() };
//       }

//       // 6. משוך את כל המוצרים + סוגי מוצר
//       let productsData = [];
//       if (donationData.products && donationData.products.length > 0) {
//         for (let productId of donationData.products) {
//           const prodSnap = await db.collection("product").doc(productId).get();
//           if (!prodSnap.exists) continue;

//           const prod = prodSnap.data();

//           // משוך סוג מוצר
//           let productTypeData = null;
//           if (prod.productType) {
//             const typeSnap = await db.collection("productType").doc(prod.productType).get();
//             if (typeSnap.exists) productTypeData = { id: typeSnap.id, ...typeSnap.data() };
//           }

//           productsData.push({
//             id: prodSnap.id,
//             quantity: prod.quantity,
//             ...prod,
//             productTypeData,
//           });
//         }
//       }
      
//     console.log('userData: ', userData);
//     console.log("donorData: ", donorData);
//     console.log("addressData: ", addressData);
//     console.log("productsData: ", productsData);

//       // 7. החזר JSON מלא
//       return res.status(200).send({
//         donation: {
//           id: donationSnap.id,
//           ...donationData,
//           created_at: normalize(donationData.created_at),
//         },
//         user: userData,
//         donor: donorData,
//         address: addressData,
//         products: productsData,
//       });
//     } catch (e) {
//       console.error("Error fetching donation:", e);
//       return res.status(500).send({ error: e.message });
//     }
//   });
// };



// functions/donations/getDonationById.js
const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    try {
      const donationId = req.query.donationId;
      if (!donationId) return res.status(400).send({ error: "Missing donation ID" });

      const donationSnap = await db.collection("donation").doc(donationId).get();
      if (!donationSnap.exists) return res.status(404).send({ error: "Donation not found" });

      const donationData = donationSnap.data();

      const normalize = (ts) => ts?.toDate ? ts.toDate().toISOString() : ts;

      // 🔹 שלוף כתובת מלאה במקום רק ID
      let addressData = null;
      if (donationData.businessAddress) {
        const addressSnap = await db.collection("address").doc(donationData.businessAddress).get();
        if (addressSnap.exists) addressData = { id: addressSnap.id, ...addressSnap.data() };
      }

      // 🔹 שלוף את כל המוצרים עם סוג המוצר מלא
      let productsData = [];
      if (donationData.products && donationData.products.length > 0) {
        for (let productId of donationData.products) {
          const prodSnap = await db.collection("product").doc(productId).get();
          if (!prodSnap.exists) continue;

          const prod = prodSnap.data();

          // סוג מוצר מלא
          let productTypeData = null;
          if (prod.productType) {
            const typeSnap = await db.collection("productType").doc(prod.productType).get();
            if (typeSnap.exists) productTypeData = { id: typeSnap.id, ...typeSnap.data() };
          }

          productsData.push({
            id: prodSnap.id,
            quantity: prod.quantity,
            type: productTypeData,  // 🔹 כאן השתנה מ-ID לאובייקט מלא
            productTypeData,        // אפשר להשאיר או למחוק, זה אותו הדבר
          });
        }
      }

      // 🔹 החזר JSON מותאם למודל Dart
      return res.status(200).send({
        donation: {
          id: donationSnap.id,
          status: donationData.status,
          receipt: donationData.recipe || '',
          canceling_reason: donationData.canceling_reason || '',
          organization_id: donationData.organization_id || '',
          donor_id: donationData.donor_id || '',
          driver_id: donationData.driver_id || '',
          contactName: donationData.contactName || '',
          contactPhone: donationData.contactPhone || '',
          created_at: normalize(donationData.created_at),
          businessAddress: addressData || { id: 'MISSING', lat: 0, lng: 0, name: '' },
          pickupTimes: donationData.pickupTimes || [],
          products: productsData,
        },
      });

    } catch (e) {
      console.error("Error fetching donation:", e);
      return res.status(500).send({ error: e.message });
    }
  });
};