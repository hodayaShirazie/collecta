const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");

const db = admin.firestore();

module.exports = async (req, res) => {

  corsHandler(req, res, async () => {

    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {

      const { id, name, day, addressId } = req.body;

      if (!id) {
        return res.status(400).send({ error: "Destination id required" });
      }

      const updateData = {};

      if (name !== undefined) updateData.name = name;
      if (day !== undefined) updateData.day = day;
      if (addressId !== undefined) updateData.addressId = addressId;

      await db
        .collection("destination")
        .doc(id)
        .update(updateData);

      return res.status(200).send({
        status: "success",
      });

    } catch (e) {

      return res.status(500).send({
        error: e.message,
      });

    }

  });

};