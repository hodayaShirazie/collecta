const functions = require("firebase-functions");
const axios = require("axios");
const { defineJsonSecret } = require("firebase-functions/params");
const cors = require("../utils/cors");
const config = defineJsonSecret("FUNCTIONS_CONFIG_EXPORT");
const verifyFirebaseToken = require("../utils/verifyToken");


exports.placesAutocomplete = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;
    
    try {
      const input = req.query.input || req.body.input;

      if (!input) {
        return res.status(400).json({ error: "Missing input" });
      }

      const GOOGLE_KEY = config.value().google.key;
      console.log("GOOGLE KEY:", GOOGLE_KEY);

      const response = await axios.get(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json",
        {
          params: {
            input,
            types: "address",
            language: "he",
            key: GOOGLE_KEY,
          },
        }
      );

      const predictions = response.data.predictions.map((p) => ({
        description: p.description,
        placeId: p.place_id,
      }));

      return res.status(200).json(predictions);

    } catch (error) {
      console.error("Google Places error:", error.response?.data || error.message);
      return res.status(500).json({ error: "Failed to fetch places" });
    }
  });
});
