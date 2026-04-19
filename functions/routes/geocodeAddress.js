const functions = require("firebase-functions");
const axios = require("axios");
const cors = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const { isValidString } = require("../utils/validate");

exports.geocodeAddress = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const address = req.query.address || req.body.address;

      if (!address) {
        return res.status(400).json({ error: "Missing address" });
      }

      if (!isValidString(address)) {
        return res.status(400).json({ error: "Invalid address" });
      }

      const response = await axios.get(
        "https://nominatim.openstreetmap.org/search",
        {
          params: {
            q: address,
            countrycodes: "il",
            format: "json",
            limit: 1,
          },
          headers: {
            "User-Agent": "Collecta/1.0",
          },
        }
      );

      if (!response.data || response.data.length === 0) {
        return res.status(404).json({ error: "Address not found" });
      }

      const result = response.data[0];
      return res.status(200).json({
        lat: parseFloat(result.lat),
        lng: parseFloat(result.lon),
      });

    } catch (error) {
      console.error("Nominatim geocoding error:", error.message);
      return res.status(500).json({ error: "Failed to geocode address" });
    }
  });
});
