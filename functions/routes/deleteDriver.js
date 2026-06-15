const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const axios = require("axios");

const LGCN_BASE_URL = "http://46.224.67.125:8000";

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    if (req.method === "OPTIONS") {
      return res.status(204).send("");
    }

    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const driverId = req.path.split("/").filter(Boolean).pop();

      if (!driverId) {
        return res.status(400).send({ error: "Missing driver_id" });
      }

      const lgcnResponse = await axios.delete(
        `${LGCN_BASE_URL}/driver/${driverId}`,
        { headers: { "Content-Type": "application/json" } }
      );

      return res.status(200).send(lgcnResponse.data);
    } catch (e) {
      const detail = e.response
        ? { status: e.response.status, data: e.response.data }
        : e.message;
      console.error("deleteDriver error:", JSON.stringify(detail));
      return res.status(500).send({ error: e.message, detail });
    }
  });
};
