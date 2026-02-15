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

// מאפשר כל מקור (*) - מתאים לפיתוח ב-Web
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


// exports.getUsers = functions.https.onRequest((req, res) => {
//   corsHandler(req, res, async () => {
//     try {
//       const snapshot = await db.collection("user").get();
//       const users = snapshot.docs.map((doc) => ({
//         id: doc.id,
//         ...doc.data(),
//       }));
//       res.status(200).json(users);
//     } catch (e) {
//       res.status(500).json({ error: e.message });
//     }
//   });
// });

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

// exports.getOrganizations = functions.https.onRequest((req, res) => {
//   corsHandler(req, res, async () => {
//     const user = await verifyFirebaseToken(req, res);
//     if (!user) return;

//     try {
//       const snapshot = await db.collection("organization").get();
//       const organizations = snapshot.docs.map((doc) => ({
//         id: doc.id,
//         ...doc.data(),
//       }));
//       res.status(200).json(organizations);
//     } catch (e) {
//       res.status(500).json({ error: e.message });
//     }
//   });
// });


//   exports.createUser = functions.https.onRequest(async (req, res) => {
//   try {
//     if (req.method !== 'POST') {
//       return res.status(405).send({ error: 'Only POST allowed' });
//     }

//     const { name, mail, img } = req.body;

//     if (!name || !mail) {
//       return res.status(400).send({ error: 'Missing fields' });
//     }

//     const userRef = admin.firestore().collection('user'); 
//     const newUserData = {
//       name,
//       mail,
//       img: img || '',
//       createdAt: admin.firestore.FieldValue.serverTimestamp(),
//     };

//     // Firestore יוצר UID אוטומטי
//     const docRef = await userRef.add(newUserData);

//     return res.status(200).send({
//       status: 'created',
//       user: { id: docRef.id, ...newUserData }
//     });

//   } catch (error) {
//     console.error(error);
//     return res.status(500).send({ error: error.message });
//   }
// });

exports.createUser = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    const user = await verifyFirebaseToken(req, res);
    if (!user) return;

    try {
      if (req.method !== "POST") {
        return res.status(405).send({ error: "Only POST allowed" });
      }

      const { name, img } = req.body;

      if (!name) {
        return res.status(400).send({ error: "Missing name" });
      }

      const newUserData = {
        uid: user.uid,
        name,
        mail: user.email || "",
        img: img || "",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      const docRef = await db.collection("user").doc(user.uid).set(newUserData);

      return res.status(200).send({ status: "created", user: newUserData });
    } catch (error) {
      return res.status(500).send({ error: error.message });
    }
  });
});



// exports.syncUserWithRole = functions.https.onRequest((req, res) => {
//   corsHandler(req, res, async () => {
//     try {
//       const { name, mail, img, role, organizationId } = req.body;

//       if (!name || !mail || !role) {
//         return res.status(400).send({ error: "Missing fields" });
//       }

//       const userQuery = await db
//         .collection("user")
//         .where("mail", "==", mail)
//         .limit(1)
//         .get();

//       let userId;

//       if (userQuery.empty) {
//         // יצירת משתמש חדש
//         const userRef = await db.collection("user").add({
//           name,
//           mail,
//           img: img || "",
//           created_at: admin.firestore.FieldValue.serverTimestamp(),
//         });

//         userId = userRef.id;

//         // יצירת role
//         if (role === "driver") {
//           await db.collection("driver").doc(userId).set({
//             id: userId,
//             organization_id: organizationId,
//             created_at: admin.firestore.FieldValue.serverTimestamp(),
//           });
//         } else {
//           await db.collection("donor").doc(userId).set({
//             id: userId,
//             organization_id: organizationId,
//             created_at: admin.firestore.FieldValue.serverTimestamp(),
//           });
//         }

//         return res.status(200).send({ status: "success" });
//       }

//       // אם קיים
//       userId = userQuery.docs[0].id;

//       const roleDoc = await db.collection(role).doc(userId).get();

//       if (!roleDoc.exists) {
//         return res.status(400).send({
//           error: "User already registered with different role",
//         });
//       }

//       return res.status(200).send({ status: "success" });

//     } catch (error) {
//       return res.status(500).send({ error: error.message });
//     }
//   });
// });


exports.syncUserWithRole = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    const user = await verifyFirebaseToken(req, res);
    if (!user) return;

    try {
      const { role, organizationId, img, name } = req.body;

      if (!role || !organizationId) {
        return res.status(400).send({ error: "Missing fields" });
      }

      const uid = user.uid;
      const mail = user.email || "";

      const userRef = db.collection("user").doc(uid);
      const userSnap = await userRef.get();

      if (!userSnap.exists) {
        await userRef.set({
          uid,
          name: name || "",
          mail,
          img: img || "",
          created_at: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      const roleRef = db.collection(role).doc(uid);
      const roleDoc = await roleRef.get();

      if (!roleDoc.exists) {
        await roleRef.set({
          id: uid,
          organization_id: organizationId,
          created_at: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      return res.status(200).send({ status: "success" });
    } catch (error) {
      return res.status(500).send({ error: error.message });
    }
  });
});
