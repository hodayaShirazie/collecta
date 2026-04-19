
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

      // שלוף כתובת + כל המוצרים במקביל
      const [addressSnap, ...productSnaps] = await Promise.all([
        donationData.businessAddress
          ? db.collection("address").doc(donationData.businessAddress).get()
          : Promise.resolve(null),
        ...(donationData.products || []).map(id =>
          db.collection("product").doc(id).get()
        )
      ]);

      const addressData = addressSnap && addressSnap.exists
        ? { id: addressSnap.id, ...addressSnap.data() }
        : null;

      // שלוף product types של כל המוצרים במקביל
      const productsData = await Promise.all(
        productSnaps
          .filter(snap => snap.exists)
          .map(async (prodSnap) => {
            const prod = prodSnap.data();
            const typeSnap = prod.productType
              ? await db.collection("productType").doc(prod.productType).get()
              : null;
            const productTypeData = typeSnap && typeSnap.exists
              ? { id: typeSnap.id, ...typeSnap.data() }
              : null;

            return {
              id: prodSnap.id,
              quantity: prod.quantity,
              type: productTypeData,
            };
          })
      );

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