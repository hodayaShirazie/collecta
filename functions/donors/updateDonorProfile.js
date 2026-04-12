const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const { isValidString } = require("../utils/validate");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    try {
      const uid = firebaseUser.uid;

      const {
        businessName,
        businessPhone,
        businessAddress,
        contactName,
        contactPhone,
        crn,
      } = req.body;

      if (
        (businessName !== undefined && !isValidString(businessName)) ||
        (businessPhone !== undefined && !isValidString(businessPhone)) ||
        (businessAddress !== undefined && !isValidString(businessAddress)) ||
        (contactName !== undefined && !isValidString(contactName)) ||
        (contactPhone !== undefined && !isValidString(contactPhone)) ||
        (crn !== undefined && !isValidString(crn))
      ) {
        return res.status(400).send({ error: "Invalid input parameters" });
      }

      const updateData = {};
      if (businessName !== undefined) updateData.businessName = businessName;
      if (businessPhone !== undefined) updateData.businessPhone = businessPhone;
      if (businessAddress !== undefined) updateData.businessAddress = businessAddress;
      if (contactName !== undefined) updateData.contactName = contactName;
      if (contactPhone !== undefined) updateData.contactPhone = contactPhone;
      if (crn !== undefined) updateData.crn = crn;

      if (Object.keys(updateData).length === 0) {
        return res.status(400).send({ error: "No fields to update" });
      }

      await db.collection("donor").doc(uid).update(updateData);

      return res.status(200).send({ status: "success" });
    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};

