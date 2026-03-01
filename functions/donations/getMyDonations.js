const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {

    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;
    

    try {

      const snapshot = await db
        .collection("donation")
        .where("donor_id", "==", firebaseUser.uid)
        // .orderBy("created_at", "desc")
        .get();

      const donations = [];

      for (const doc of snapshot.docs) {
        const donationData = doc.data();

        // 🔹 JOIN ADDRESS
        const addressDoc = await db
          .collection("address")
          .doc(donationData.businessAddress)
          .get();

        const addressData = addressDoc.exists
          ? addressDoc.data()
          : { lat: 0, lng: 0, name: "לא ידוע" };

        // 🔹 JOIN PRODUCTS
        const productsDetailed = [];

        for (const productId of donationData.products || []) {

          const productDoc = await db.collection("product").doc(productId).get();
          if (!productDoc.exists) continue;

          const productData = productDoc.data();

          const productTypeDoc = await db
            .collection("productType")
            .doc(productData.productType)
            .get();

          const productTypeData = productTypeDoc.exists
            ? productTypeDoc.data()
            : { name: "לא ידוע", description: "" };

          productsDetailed.push({
            id: productDoc.id,
            quantity: productData.quantity,
            type: {
              id: productData.productType,
              name: productTypeData.name,
              description: productTypeData.description || ""
            }
          });
        }

        donations.push({
          id: doc.id,
          status: donationData.status,
          receipt: donationData.receipt || "",
          canceling_reason: donationData.canceling_reason || "",
          organization_id: donationData.organization_id,
          donor_id: donationData.donor_id,
          driver_id: donationData.driver_id || "",
          contactName: donationData.contactName,
          contactPhone: donationData.contactPhone,
          created_at: donationData.created_at.toDate().toISOString(),
          businessAddress: {
            id: addressDoc.id,
            lat: addressData.lat,
            lng: addressData.lng,
            name: addressData.name
          },
          pickupTimes: donationData.pickupTimes || [],
          products: productsDetailed
        });
      }

      return res.status(200).send(donations);

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }

  });
};
