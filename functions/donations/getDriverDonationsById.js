// functions/donations/getDriverDonations.js
const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const resolveUid = require("../utils/resolveUid");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    try {
      const uid = await resolveUid(req, res);
      if (!uid) return;

      const snapshot = await db
        .collection("donation")
        .where("driver_id", "==", uid)
        .where("status", "==", "pending")
        .orderBy("created_at", "desc")
        .get();

      const normalize = (ts) => ts?.toDate ? ts.toDate().toISOString() : ts;
      const donations = [];

      for (const doc of snapshot.docs) {
        const donationData = doc.data();

        // שליפת כתובת
        let addressData = { id: 'MISSING', lat: 0, lng: 0, name: '' };
        if (donationData.businessAddress) {
          const addressSnap = await db.collection("address").doc(donationData.businessAddress).get();
          if (addressSnap.exists) addressData = { id: addressSnap.id, ...addressSnap.data() };
        }

        // שליפת מוצרים
        let productsData = [];
        if (donationData.products && donationData.products.length > 0) {
          for (let productId of donationData.products) {
            const prodSnap = await db.collection("product").doc(productId).get();
            if (!prodSnap.exists) continue;
            const prod = prodSnap.data();

            let productTypeData = null;
            if (prod.productType) {
              const typeSnap = await db.collection("productType").doc(prod.productType).get();
              if (typeSnap.exists) productTypeData = { id: typeSnap.id, ...typeSnap.data() };
            }

            productsData.push({
              id: prodSnap.id,
              quantity: prod.quantity,
              type: productTypeData
            });
          }
        }

        donations.push({
          id: doc.id,
          status: donationData.status,
          receipt: donationData.recipe || donationData.receipt || '',
          canceling_reason: donationData.canceling_reason || '',
          organization_id: donationData.organization_id || '',
          donor_id: donationData.donor_id || '',
          driver_id: donationData.driver_id || '',
          contactName: donationData.contactName || '',
          contactPhone: donationData.contactPhone || '',
          created_at: normalize(donationData.created_at),
          businessAddress: addressData,
          pickupTimes: donationData.pickupTimes || [],
          products: productsData,
        });
      }

      return res.status(200).send(donations);

    } catch (e) {
      console.error("Error fetching driver donations:", e);
      return res.status(500).send({ error: e.message });
    }
  });
};