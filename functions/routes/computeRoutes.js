const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const axios = require("axios");

const LGCN_URL = "http://46.224.67.125:8000/compute-routes";

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    if (req.method === "OPTIONS") {
      return res.status(204).send("");
    }

    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const { points } = req.body;

      if (!points || !Array.isArray(points) || points.length === 0) {
        return res.status(400).send({ error: "Missing or invalid points" });
      }

      const lgcnResponse = await axios.post(
        LGCN_URL,
        { nodes: points },
        { headers: { "Content-Type": "application/json" } }
      );

      return res.status(200).send(lgcnResponse.data);

    } catch (e) {
      const detail = e.response
        ? { status: e.response.status, data: e.response.data }
        : e.message;
      console.error("computeRoutes error:", JSON.stringify(detail));
      return res.status(500).send({ error: e.message, detail });
    }
  });
};
