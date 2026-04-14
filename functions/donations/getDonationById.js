
// functions/donations/getDonationById.js
const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const { isValidString } = require("../utils/validate");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    try {
      
      const firebaseUser = await verifyFirebaseToken(req, res);
      if (!firebaseUser) return;

      const donationId = req.query.donationId;
      if (!donationId) return res.status(400).send({ error: "Missing donation ID" });

      if (!isValidString(donationId)) {
        return res.status(400).send({ error: "Invalid input parameters" });
      }

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
          businessName: donationData.businessName || '',
          businessPhone: donationData.businessPhone || '',
          crn: donationData.crn || '',
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