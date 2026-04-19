const admin = require("firebase-admin");
const db = admin.firestore();

const WEEKDAYS = ["ראשון", "שני", "שלישי", "רביעי", "חמישי"];

/**
 * Creates a driver role document and 5 empty destination records
 * (one per weekday: ראשון–חמישי) linked to the driver.
 *
 * @param {string} uid          - The driver's Firebase UID
 * @param {string} role         - Firestore collection name (always "driver")
 * @param {string} organizationId - The organisation this driver belongs to
 */
async function createDriver(uid, role, organizationId = "") {
  // 1. Create the base driver document with an empty destination list
  await db.collection(role).doc(uid).set({
    id: uid,
    phone: "",
    areas: [],
    destination: [],
    stops: [],
  });

  // 2. Create 5 empty destination documents (one per weekday), no address yet
  const destinationIds = [];

  for (const day of WEEKDAYS) {
    const destRef = await db.collection("destination").add({
      name: "",
      day: day,
      organizationId: organizationId,
      addressId: "",
      driverId: uid,
    });

    destinationIds.push(destRef.id);
  }

  // 3. Store the destination IDs on the driver document
  await db.collection(role).doc(uid).update({
    destination: destinationIds,
  });
}

module.exports = { createDriver };
