// utils/resolveUid.js
const admin = require("firebase-admin");
const verifyFirebaseToken = require("./verifyToken");

const db = admin.firestore();

/**
 * Resolves the effective UID for a request.
 *
 * Normal case: returns the UID from the verified Firebase token.
 *
 * Impersonation case: if the request carries the X-Impersonate-User header
 * AND the authenticated user is an admin in Firestore, returns the
 * impersonated driver's UID instead.
 * The original admin UID is logged for audit purposes.
 *
 * Returns null and sends a 401/403 response if anything fails.
 */
module.exports = async function resolveUid(req, res) {
  const firebaseUser = await verifyFirebaseToken(req, res);
  if (!firebaseUser) return null;

  const impersonateHeader = req.headers["x-impersonate-user"];

  // No impersonation requested → normal flow
  if (!impersonateHeader) {
    return firebaseUser.uid;
  }

  // Verify the caller is actually an admin
  const adminSnap = await db.collection("admin").doc(firebaseUser.uid).get();
  if (!adminSnap.exists) {
    res.status(403).json({ error: "Impersonation not allowed: caller is not an admin" });
    return null;
  }

  console.log(
    `[impersonation] admin=${firebaseUser.uid} acting as driver=${impersonateHeader}`
  );

  return impersonateHeader;
};
