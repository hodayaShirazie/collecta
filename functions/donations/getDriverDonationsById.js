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

      if (snapshot.empty) return res.status(200).send([]);

      const normalize = (ts) => ts?.toDate ? ts.toDate().toISOString() : ts;
      const docsData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

      // Collect all unique IDs across all donations
      const addressIds = [...new Set(docsData.map(d => d.businessAddress).filter(Boolean))];
      const productIds = [...new Set(docsData.flatMap(d => d.products || []))];

      // Fetch all addresses and products in parallel (single round-trip per collection)
      const [addressDocs, productDocs] = await Promise.all([
        Promise.all(addressIds.map(id => db.collection("address").doc(id).get())),
        Promise.all(productIds.map(id => db.collection("product").doc(id).get())),
      ]);

      const addressMap = {};
      addressDocs.forEach(doc => {
        if (doc.exists) addressMap[doc.id] = { id: doc.id, ...doc.data() };
      });

      const productMap = {};
      productDocs.forEach(doc => {
        if (doc.exists) productMap[doc.id] = { id: doc.id, ...doc.data() };
      });

      // Collect unique productType IDs and fetch them all at once
      const productTypeIds = [...new Set(
        Object.values(productMap).map(p => p.productType).filter(Boolean)
      )];
      const productTypeDocs = await Promise.all(
        productTypeIds.map(id => db.collection("productType").doc(id).get())
      );

      const productTypeMap = {};
      productTypeDocs.forEach(doc => {
        if (doc.exists) productTypeMap[doc.id] = { id: doc.id, ...doc.data() };
      });

      const donations = docsData.map(donationData => {
        const addressData = donationData.businessAddress
          ? (addressMap[donationData.businessAddress] || { id: "MISSING", lat: 0, lng: 0, name: "" })
          : { id: "MISSING", lat: 0, lng: 0, name: "" };

        const productsData = (donationData.products || [])
          .map(productId => {
            const product = productMap[productId];
            if (!product) return null;
            const productType = product.productType ? productTypeMap[product.productType] : null;
            return {
              id: productId,
              quantity: product.quantity,
              type: productType || null,
            };
          })
          .filter(Boolean);

        return {
          id: donationData.id,
          status: donationData.status,
          receipt: donationData.recipe || donationData.receipt || "",
          canceling_reason: donationData.canceling_reason || "",
          organization_id: donationData.organization_id || "",
          donor_id: donationData.donor_id || "",
          driver_id: donationData.driver_id || "",
          businessName: donationData.businessName || "",
          businessPhone: donationData.businessPhone || "",
          crn: donationData.crn || "",
          contactName: donationData.contactName || "",
          contactPhone: donationData.contactPhone || "",
          created_at: normalize(donationData.created_at),
          businessAddress: addressData,
          pickupTimes: donationData.pickupTimes || [],
          products: productsData,
        };
      });

      return res.status(200).send(donations);

    } catch (e) {
      console.error("Error fetching driver donations:", e);
      return res.status(500).send({ error: e.message });
    }
  });
};
