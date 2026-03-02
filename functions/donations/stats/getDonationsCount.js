const admin = require("firebase-admin");
const corsHandler = require("../../utils/cors");
const verifyFirebaseToken = require("../../utils/verifyToken");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {

    if (req.method === "OPTIONS") {
      return res.status(204).send("");
    }

    const user = await verifyFirebaseToken(req, res);
    if (!user) return;

    const organizationId = req.query.organizationId;
    if (!organizationId) {
      return res.status(400).send({ error: "organizationId is required" });
    }

    try {
      const now = new Date();
      const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

      const snap = await db
        .collection("donation")
        .where("organization_id", "==", organizationId)
        .get();

      return res.status(200).send({ count: snap.size });

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};
