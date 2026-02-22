const admin = require("firebase-admin");
const db = admin.firestore();

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

module.exports = { createDriver };
