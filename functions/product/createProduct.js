const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const { productTypeId, quantity } = req.body;

      if (
        typeof productTypeId !== "string" ||
        typeof quantity !== "number" ||
        quantity <= 0
      ) {
        return res.status(400).send({ error: "Invalid fields" });
      }

      const productTypeDoc = await db
        .collection("productType")
        .doc(productTypeId)
        .get();

      if (!productTypeDoc.exists) {
        return res.status(400).send({ error: "Invalid productTypeId" });
      }

      const productData = {
        productType: productTypeId, 
        quantity
      };

      const docRef = await db.collection("product").add(productData);

      return res.status(200).send({
        status: "success",
        productId: docRef.id
      });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};
