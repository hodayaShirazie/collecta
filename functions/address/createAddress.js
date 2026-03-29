const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const { isValidString } = require("../utils/validate");
const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const {
        name,
        lat,
        lng
      } = req.body;

      if (
        !name ||
        lat === undefined ||
        lng === undefined
      ) {
        return res.status(400).send({ error: "Missing fields" });
      }

      if (!isValidString(name)) {
        return res.status(400).send({ error: "Invalid input parameters" });
      }

      const addressData = {
        name,
        lat,
        lng
      };

      const docRef = await db.collection("address").add(addressData);

      return res.status(200).send({
        status: "success",
        addressId: docRef.id
      });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};
