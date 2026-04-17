// functions/users/updateUserProfile.js
const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const resolveUid = require("../utils/resolveUid");
const { isValidString } = require("../utils/validate");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {
    const uid = await resolveUid(req, res);
    if (!uid) return;

    try {
    //   const { name, img } = req.body;
      const { name } = req.body;

      if (name !== undefined && !isValidString(name)) {
        return res.status(400).send({ error: "Invalid input parameters" });
      }

      const updateData = {};
      if (name !== undefined && name !== '') updateData.name = name;
    //   if (img !== undefined) updateData.img = img;

      if (Object.keys(updateData).length === 0) {
        return res.status(400).send({ error: "No fields to update" });
      }

      await db.collection("user").doc(uid).update(updateData);

      return res.status(200).send({ status: "success" });
    } catch (e) {
      return res.status(500).send({ error: e.message });
    }
  });
};