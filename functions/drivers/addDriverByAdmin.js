const { createDriver } = require("./utils");
const verifyFirebaseToken = require("../utils/verifyToken");
const corsHandler = require("../utils/cors");
const admin = require("firebase-admin");
const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const { name, email, phone, organizationId } = req.body;

      if (!name || !email || !organizationId) {
        return res.status(400).send({ error: "Missing required fields" });
      }

      // Check if user with this email already exists in Firestore
      const userCollection = db.collection("user");
      const existingQuery = await userCollection.where("mail", "==", email).get();

      if (!existingQuery.empty) {
        return res.status(409).send({ error: "משתמש עם כתובת מייל זו כבר קיים במערכת" });
      }

      // Create or retrieve Firebase Auth user
      let authUser;
      try {
        authUser = await admin.auth().createUser({
          email: email,
          emailVerified: false,
          disabled: false,
        });
      } catch (authError) {
        if (authError.code === "auth/email-already-exists") {
          authUser = await admin.auth().getUserByEmail(email);
        } else {
          throw authError;
        }
      }

      const uid = authUser.uid;

      // Create user doc in Firestore
      await db.collection("user").doc(uid).set({
        uid,
        name: name.trim(),
        mail: email,
        img: "",
        organization_id: organizationId,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        last_login: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Create driver doc in Firestore
      await createDriver(uid, "driver");

      // Update phone if provided
      if (phone && phone.trim().length > 0) {
        await db.collection("driver").doc(uid).update({ phone: phone.trim() });
      }

      return res.status(200).send({ status: "success", uid });

    } catch (error) {
      return res.status(500).send({ error: error.message });
    }
  });
};
