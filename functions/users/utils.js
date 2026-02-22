const admin = require("firebase-admin");
const db = admin.firestore();

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

async function createAdmin(uid, role) {
  const roleData = {
    id: uid,
    // Add any additional role-specific fields here
  };

  await db.collection(role).doc(uid).set(roleData);
}

module.exports = { createUser };
module.exports = { createAdmin };
