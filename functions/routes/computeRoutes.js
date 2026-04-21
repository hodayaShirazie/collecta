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
      const { nodes, num_drivers, driver_starts } = req.body;

      if (!nodes || !Array.isArray(nodes) || nodes.length === 0) {
        return res.status(400).send({ error: "Missing or invalid nodes" });
      }

      const lgcnResponse = await axios.post(
        LGCN_URL,
        {
          nodes,
          num_drivers: num_drivers ?? 1,
          driver_starts: driver_starts ?? [0],
        },
        { headers: { "Content-Type": "application/json" } }
      );

      return res.status(200).send(lgcnResponse.data);

    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};
