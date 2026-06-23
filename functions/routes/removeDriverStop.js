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
      const pathParts = req.path.split("/").filter(Boolean);
      // Expected path: /removeDriverStop/<driver_id>
      const driverId = pathParts[pathParts.length - 1];
      const { x, y } = req.query;

      if (!driverId || !x || !y) {
        return res.status(400).send({ error: "Missing driver_id, x or y" });
      }

      const lgcnResponse = await axios.delete(
        `${LGCN_BASE_URL}/driver/${driverId}/stop`,
        {
          params: { x, y },
          headers: { "Content-Type": "application/json" },
        }
      );

      return res.status(200).send(lgcnResponse.data);
    } catch (e) {
      if (e.response?.status === 404) {
        // Stop not in cache — not an error, just a no-op
        return res.status(200).send({ status: "not_found" });
      }
      const detail = e.response
        ? { status: e.response.status, data: e.response.data }
        : e.message;
      console.error("removeDriverStop error:", JSON.stringify(detail));
      return res.status(500).send({ error: e.message, detail });
    }
  });
};
