const admin = require("firebase-admin");
const corsHandler = require("../../utils/cors");
const verifyFirebaseToken = require("../../utils/verifyToken");
const db = admin.firestore();

// Function to report a donation
module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const {
        name,
        description
      } = req.body;

      if (
        !name ||
        !description
      ) {
        return res.status(400).send({ error: "Missing fields" });
      }

      const productTypeData = {
        name,
        description
      };

      const docRef = await db.collection("productType").add(productTypeData);

      return res.status(200).send({
        status: "success",
        productTypeId: docRef.id
      });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};
