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

      const donations = await Promise.all(snapshot.docs.map(async (doc) => {
        const donationData = doc.data();

        // JOIN ADDRESS + כל המוצרים במקביל
        const [addressDoc, ...productDocs] = await Promise.all([
          db.collection("address").doc(donationData.businessAddress).get(),
          ...(donationData.products || []).map(id =>
            db.collection("product").doc(id).get()
          )
        ]);

        const addressData = addressDoc.exists
          ? addressDoc.data()
          : { lat: 0, lng: 0, name: "לא ידוע" };

        // JOIN PRODUCT TYPES במקביל
        const productsDetailed = await Promise.all(
          productDocs
            .filter(productDoc => productDoc.exists)
            .map(async (productDoc) => {
              const productData = productDoc.data();
              const productTypeDoc = await db
                .collection("productType")
                .doc(productData.productType)
                .get();

              const productTypeData = productTypeDoc.exists
                ? productTypeDoc.data()
                : { name: "לא ידוע", description: "" };

              return {
                id: productDoc.id,
                quantity: productData.quantity,
                type: {
                  id: productData.productType,
                  name: productTypeData.name,
                  description: productTypeData.description || ""
                }
              };
            })
        );

        return {
          id: doc.id,
          status: donationData.status,
          receipt: donationData.receipt || donationData.recipe || "",
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
        };
      }));

      return res.status(200).send(donations);

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }

  });
};
