const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const { isValidString } = require("../utils/validate");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {

    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    const organizationId = req.query.organizationId;
    if (!organizationId) {
      return res.status(400).send({ error: "organizationId is required" });
    }

    if (!isValidString(organizationId)) {
      return res.status(400).send({ error: "Invalid input parameters" });
    }

    try {
      const snapshot = await db
        .collection("donation")
        .where("organization_id", "==", organizationId)
        .orderBy("created_at", "desc")
        .get();

      if (snapshot.empty) return res.status(200).send([]);

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
        const address = donationData.businessAddress
          ? (addressMap[donationData.businessAddress] || { id: "MISSING", lat: 0, lng: 0, name: "לא ידוע" })
          : { id: "MISSING", lat: 0, lng: 0, name: "לא ידוע" };

        const products = (donationData.products || [])
          .map(productId => {
            const product = productMap[productId];
            if (!product) return null;
            const type = product.productType ? productTypeMap[product.productType] : null;
            return {
              id: productId,
              quantity: product.quantity,
              type: type
                ? { id: type.id, name: type.name, description: type.description || "" }
                : { id: "", name: "לא ידוע", description: "" },
            };
          })
          .filter(Boolean);

        return {
          id: donationData.id,
          status: donationData.status,
          receipt: donationData.receipt || donationData.recipe || "",
          canceling_reason: donationData.canceling_reason || "",
          organization_id: donationData.organization_id,
          donor_id: donationData.donor_id,
          driver_id: donationData.driver_id || "",
          businessName: donationData.businessName || "",
          businessPhone: donationData.businessPhone || "",
          crn: donationData.crn || "",
          contactName: donationData.contactName,
          contactPhone: donationData.contactPhone,
          created_at: donationData.created_at.toDate().toISOString(),
          businessAddress: {
            id: address.id,
            lat: address.lat,
            lng: address.lng,
            name: address.name,
          },
          pickupTimes: donationData.pickupTimes || [],
          products,
        };
      });

      return res.status(200).send(donations);

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }

  });
};
