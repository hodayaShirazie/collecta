const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const organizationId = req.query.organizationId;

      if (!organizationId) {
        return res.status(400).send({ error: "Missing organizationId" });
      }

      const snapshot = await db
        .collection("donation")
        .where("donor_id", "==", firebaseUser.uid)
        .where("organization_id", "==", organizationId)
        .orderBy("created_at", "desc")
        .get();

      const donations = snapshot.docs.map(doc => {
        const donationData = doc.data();

        return {
          id: doc.id,
          status: donationData.status,
          created_at: donationData.created_at.toDate().toISOString(),
          receipt: donationData.receipt || donationData.recipe || "",
        };
      });

      return res.status(200).send(donations);

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};