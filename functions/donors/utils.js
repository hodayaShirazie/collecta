const admin = require("firebase-admin");
const db = admin.firestore();

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

module.exports = { createDonor };
