// users/roles.js
const { createDriver } = require("../drivers/utils");
const { createDonor } = require("../donors/utils");
const admin = require("firebase-admin");
const db = admin.firestore();

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


module.exports = { createRoleObject };


