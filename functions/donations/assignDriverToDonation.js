const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const { isValidString } = require("../utils/validate");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    if (req.method === "OPTIONS") {
      return res.status(204).send("");
    }

    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    const { donationId, driverId } = req.body;

    if (!isValidString(donationId) || !isValidString(driverId)) {
      return res.status(400).send({ error: "donationId and driverId are required" });
    }

    try {
      const donationRef = db.collection("donation").doc(donationId);
      const donationSnap = await donationRef.get();

      if (!donationSnap.exists) {
        return res.status(404).send({ error: "Donation not found" });
      }

      const donation = donationSnap.data();

      if (donation.status !== "pending") {
        return res.status(400).send({ error: "Only pending donations can be reassigned" });
      }

      // Verify the driver belongs to the same organization
      const adminUserSnap = await db.collection("user").doc(firebaseUser.uid).get();
      if (!adminUserSnap.exists) {
        return res.status(403).send({ error: "Unauthorized" });
      }
      const adminOrgId = adminUserSnap.data().organization_id;

      if (donation.organization_id !== adminOrgId) {
        return res.status(403).send({ error: "Unauthorized: donation does not belong to your organization" });
      }

      const driverUserSnap = await db.collection("user").doc(driverId).get();
      if (!driverUserSnap.exists) {
        return res.status(404).send({ error: "Driver not found" });
      }
      if (driverUserSnap.data().organization_id !== adminOrgId) {
        return res.status(403).send({ error: "Driver does not belong to your organization" });
      }

      // Verify it's actually a driver
      const driverRoleSnap = await db.collection("driver").doc(driverId).get();
      if (!driverRoleSnap.exists) {
        return res.status(400).send({ error: "User is not a driver" });
      }

      await donationRef.update({ driver_id: driverId });

      return res.status(200).send({ status: "ok" });
    } catch (error) {
      console.error("❌ Error in assignDriverToDonation:", error);
      return res.status(500).send({ error: error.message });
    }
  });
};
