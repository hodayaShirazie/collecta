const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const axios = require("axios");
const { defineJsonSecret } = require("firebase-functions/params");

const LGCN_URL = "http://46.224.67.125:8000/compute-routes";
const GMAPS_DISTANCE_MATRIX_URL =
  "https://maps.googleapis.com/maps/api/distancematrix/json";
const MAX_MATRIX_SIZE = 25; // Distance Matrix API limit per request

const config = defineJsonSecret("FUNCTIONS_CONFIG_EXPORT");

/**
 * Builds an NxN matrix of driving durations (seconds) between all point pairs,
 * using Google Maps Distance Matrix API with real-time traffic (departure_time=now).
 */
async function buildTrafficMatrix(points, googleKey) {
  const coords = points.map((p) => `${p[0]},${p[1]}`);
  const joined = coords.join("|");

  const response = await axios.get(GMAPS_DISTANCE_MATRIX_URL, {
    params: {
      origins: joined,
      destinations: joined,
      mode: "driving",
      departure_time: "now",
      traffic_model: "best_guess",
      key: googleKey,
    },
  });

  const { rows, status } = response.data;
  if (status !== "OK") {
    throw new Error(`Distance Matrix API returned status: ${status}`);
  }

  // duration_in_traffic is present when departure_time is set; fall back to duration
  return rows.map((row) =>
    row.elements.map((el) =>
      el.status === "OK"
        ? (el.duration_in_traffic ?? el.duration).value
        : null
    )
  );
}

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

      if (points.length > MAX_MATRIX_SIZE) {
        return res.status(400).send({
          error: `Too many points: maximum ${MAX_MATRIX_SIZE} supported per request`,
        });
      }

      const googleKey = config.value().google.key;
      const trafficMatrix = await buildTrafficMatrix(points, googleKey);

      console.log(
        `[computeRoutes] traffic_matrix built: ${points.length}x${points.length} nodes. ` +
        `Sample [0→1]: ${trafficMatrix[0]?.[1] ?? "N/A"} seconds`
      );

      const lgcnResponse = await axios.post(
        LGCN_URL,
        { nodes: points, traffic_matrix: trafficMatrix },
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
