const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const resolveUid = require("../utils/resolveUid");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    if (req.method === "OPTIONS") {
      return res.status(204).send("");
    }

    const uid = await resolveUid(req, res);
    if (!uid) return;

    try {
      await db.collection("driver").doc(uid).update({ stops: [] });
      return res.status(200).send({ status: "success" });
    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};
