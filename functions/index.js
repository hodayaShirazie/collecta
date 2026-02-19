// /**
//  * Import function triggers from their respective submodules:
//  *
//  * const {onCall} = require("firebase-functions/v2/https");
//  * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
//  *
//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
//  */

// const {setGlobalOptions} = require("firebase-functions");
// const {onRequest} = require("firebase-functions/https");
// const logger = require("firebase-functions/logger");

// // For cost control, you can set the maximum number of containers that can be
// // running at the same time. This helps mitigate the impact of unexpected
// // traffic spikes by instead downgrading performance. This limit is a
// // per-function limit. You can override the limit for each function using the
// // `maxInstances` option in the function's options, e.g.
// // `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// // NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// // functions should each use functions.runWith({ maxInstances: 10 }) instead.
// // In the v1 API, each function can only serve one request per container, so
// // this will be the maximum concurrent request count.
// setGlobalOptions({ maxInstances: 10 });

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// // exports.helloWorld = onRequest((request, response) => {
// //   logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors");


admin.initializeApp();
const db = admin.firestore();

const corsHandler = cors({ origin: true });

async function verifyFirebaseToken(req, res) {
  const authHeader = req.headers.authorization || "";

  if (!authHeader.startsWith("Bearer ")) {
    res.status(401).json({ error: "Missing Authorization Bearer token" });
    return null;
  }

  const idToken = authHeader.replace("Bearer ", "");

  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    return decoded; // { uid, email, ... }
  } catch (e) {
    res.status(401).json({ error: "Invalid or expired token" });
    return null;
  }
}


exports.getUsers = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    const user = await verifyFirebaseToken(req, res);
    if (!user) return;

    try {
      const snapshot = await db.collection("user").get();
      const users = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      res.status(200).json(users);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });
});

// TODO Add verification to check the path of the organization and only allow users with the right role to access it
exports.getOrganizations = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    try {
      const snapshot = await db.collection("organization").get();
      const organizations = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      res.status(200).json(organizations);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

});

// Function to create a new user in the "user" collection
async function createUser(firebaseUser, name, img, organizationId) {
  const uid = firebaseUser.uid;
  const mail = firebaseUser.email || "";

  const newUserData = {
    uid,
    name: name || "",
    mail,
    img: img || "",
    organization_id: organizationId,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    last_login: admin.firestore.FieldValue.serverTimestamp(),
  };

  await db.collection("user").doc(uid).set(newUserData);
  return uid;
}

// Function to create a new role object in the corresponding collection
async function createRoleObject(uid, role) {

  if (role === "admin"){
    await createAdmin(uid, role);
  }

  else if (role === "driver"){
    await createDriver(uid, role);
  }

  else if (role === "donor"){
    await createDonor(uid, role);
  }
}

async function createAdmin(uid, role) {
  const roleData = {
    id: uid,
    // Add any additional role-specific fields here
  };

  await db.collection(role).doc(uid).set(roleData);
}

async function createDriver(uid, role) {
  const roleData = {
    id: uid,
    phone: "",
    area: "",
    destination: [], 
    stops: [],             
  };

  await db.collection(role).doc(uid).set(roleData);
}

async function createDonor(uid, role) {
  const roleData = {
    id: uid,
    businessAddress_id: "",
    businessName: "",
    businessPhone: "",
    coins: 0,
    contactName: "",
    contactPhone: "",
    crn: "",
  };

  await db.collection(role).doc(uid).set(roleData);
}

// Main function to sync user with role
exports.syncUserWithRole = functions.https.onRequest((req, res) => {
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
});

exports.getMyProfile = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const { role } = req.query;

      if (!role) {
        return res.status(400).send({ error: "Missing role" });
      }

      const uid = firebaseUser.uid;

      const userSnap = await db.collection("user").doc(uid).get();
      if (!userSnap.exists) {
        return res.status(404).send({ error: "User not found" });
      }

      const roleSnap = await db.collection(role).doc(uid).get();
      if (!roleSnap.exists) {
        return res.status(404).send({ error: "Role not found" });
      }

      const userData = userSnap.data();
      const roleData = roleSnap.data();

      const normalize = (ts) =>
        ts?.toDate ? ts.toDate().toISOString() : ts;

      return res.status(200).send({
        user: {
          uid: uid,
          ...userData,
          created_at: normalize(userData.created_at),
          last_login: normalize(userData.last_login),
        },
        role: {
          id: roleSnap.id,
          ...roleData,
          created_at: normalize(roleData.created_at),
          last_login: normalize(roleData.last_login),
        },
      });
    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
});


exports.updateDonorProfile = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const uid = firebaseUser.uid;

      const {
        businessName,
        businessPhone,
        businessAddress_id,
        contactName,
        contactPhone,
        crn,
      } = req.body;

      await db.collection("donor").doc(uid).update({
        businessName,
        businessPhone,
        businessAddress_id,
        contactName,
        contactPhone,
        crn,
      });

      return res.status(200).send({ status: "success" });
    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
});
