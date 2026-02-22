// const functions = require("firebase-functions");
const { createUser } = require("./utils");
const { createRoleObject } = require("./roles");
const verifyFirebaseToken = require("../utils/verifyToken");
const corsHandler = require("../utils/cors");
const admin = require("firebase-admin");
const db = admin.firestore();

module.exports = async(req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const { role, organizationId, img, name } = req.body;

      // Check required fields
      if (!role || !organizationId) {
        return res.status(400).send({ error: "Missing fields" });
      }

      const mail = firebaseUser.email || "";
      const userCollection = db.collection("user");

      // Check if user with this email exists
      const existingUsersQuery = await userCollection.where("mail", "==", mail).get();

      if (!existingUsersQuery.empty) {
        // User exists
        const existingUserDoc = existingUsersQuery.docs[0];
        const userDocId = existingUserDoc.id;

        // Check if user has this role
        const roleRef = db.collection(role).doc(userDocId);
        const roleSnap = await roleRef.get();

        if (!roleSnap.exists) {
          // User exists but not in this role
          return res.status(403).send({
            error: `User registered with a different role. Cannot login as ${role}.`
          });
        }

        // User exists and has the correct role → success
        return res.status(200).send({ status: "success" });

      } else {
        // User does not exist → create user and role
        const uid = await createUser(firebaseUser, name, img, organizationId);

        await createRoleObject(uid, role);

        return res.status(200).send({ status: "success" });
      }

    } catch (error) {
      return res.status(500).send({ error: error.message });
    }
  });
};