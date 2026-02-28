const axios = require("axios");
const { defineJsonSecret } = require("firebase-functions/params");
const config = defineJsonSecret("FUNCTIONS_CONFIG_EXPORT");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");

module.exports = (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;
    try {
      const placeId = req.query.placeId || req.body.placeId;

      if (!placeId) {
        return res.status(400).send({ error: "Missing placeId" });
      }

      const GOOGLE_KEY = config.value().google.key;

      const response = await axios.get(
        "https://maps.googleapis.com/maps/api/place/details/json",
        {
          params: {
            place_id: placeId,
            fields: "geometry",
            key: GOOGLE_KEY,
          },
        }
      );

      const location = response.data.result.geometry.location;

      return res.status(200).send({
        lat: location.lat,
        lng: location.lng,
      });

    } catch (error) {
      console.error(error.response?.data || error.message);
      return res.status(500).send({ error: "Failed to fetch details" });
    }
  });
};
