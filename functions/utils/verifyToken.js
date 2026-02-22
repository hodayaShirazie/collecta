const admin = require("firebase-admin");

module.exports = async function verifyFirebaseToken(req, res) {
  const authHeader = req.headers.authorization || "";

  if (!authHeader.startsWith("Bearer ")) {
    res.status(401).json({ error: "Missing Authorization Bearer token" });
    return null;
  }

  const idToken = authHeader.replace("Bearer ", "");

  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    return decoded;
  } catch (e) {
    res.status(401).json({ error: "Invalid or expired token" });
    return null;
  }
};
