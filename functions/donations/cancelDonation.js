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
      const { donationId, cancelingReason } = req.body;

      if (!donationId || !cancelingReason) {
        return res.status(400).send({ error: "Missing required fields" });
      }

      if (!isValidString(donationId) || !isValidString(cancelingReason)) {
        return res.status(400).send({ error: "Invalid input parameters" });
      }

      const donationRef = db.collection("donation").doc(donationId);
      const donationSnap = await donationRef.get();

      if (!donationSnap.exists) {
        return res.status(404).send({ error: "Donation not found" });
      }

      const data = donationSnap.data();
      const orgId = data.organization_id || data.organizationId || "";
      const businessName = data.business_name || data.businessName || "";
      const contactName = data.contact_name || data.contactName || "";
      const contactPhone = data.contact_phone || data.contactPhone || "";

      await donationRef.update({
        status: "cancelled",
        canceling_reason: cancelingReason,
      });

      if (orgId) {
        await db.collection("notifications").add({
          type: "cancelled_donation",
          donationId,
          organizationId: orgId,
          businessName,
          contactName,
          contactPhone,
          cancelingReason,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          isRead: false,
        });
      }

      return res.status(200).send({ status: "success" });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};