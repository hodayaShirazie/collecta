const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const db = admin.firestore();

// Function to report a donation
module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const {
        businessName,
        businessAddress,
        lat,
        lng,
        businessPhone,
        businessId,
        contactName,
        contactPhone,
        products,
        pickupTimes,
        organization_id,
        driver_id = "",
        canceling_reason = "",
        recipe = ""
      } = req.body;

      if (
        !businessName ||
        !businessAddress ||
        !lat ||
        !lng ||
        !businessPhone ||
        !contactName ||
        !contactPhone ||
        !products ||
        !pickupTimes ||
        !organization_id
      ) {
        return res.status(400).send({ error: "Missing fields" });
      }

      const donationData = {
        donor_id: firebaseUser.uid,
        businessName,
        businessAddress,
        lat,
        lng,
        businessPhone,
        businessId,
        contactName,
        contactPhone,
        products,
        pickupTimes,
        driver_id,
        canceling_reason,
        recipe,
        organization_id,
        status: "PENDING",
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      };

      const docRef = await db.collection("donation").add(donationData);

      return res.status(200).send({
        status: "success",
        donationId: docRef.id
      });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};
