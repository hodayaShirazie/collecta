
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { uploadPDFToStorage } = require("./utils/uploadReceiptHelper");
const Busboy = require("busboy");
const corsHandler = require("../utils/cors"); 
const verifyFirebaseToken = require("../utils/verifyToken");

const db = admin.firestore();

module.exports = functions.https.onRequest((req, res) => {
  return corsHandler(req, res, async () => {

    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    if (req.method !== "POST") {
      return res.status(405).send("Method Not Allowed");
    }

    const busboy = Busboy({ headers: req.headers });
    let uploadData = null;
    let donationId = null;

    busboy.on("field", (fieldname, val) => {
      if (fieldname === "donationId") {
        donationId = val;
      }
    });

    busboy.on("file", (fieldname, file, info) => {
      const { filename, mimeType } = info;
      if (fieldname !== "file") {
        file.resume();
        return;
      }

      const buffers = [];
      file.on("data", (data) => buffers.push(data));
      file.on("end", () => {
        uploadData = {
          buffer: Buffer.concat(buffers),
          originalname: filename,
          mimetype: mimeType,
        };
      });
    });

    busboy.on("finish", async () => {
      if (!uploadData || !donationId) {
        return res.status(400).json({ error: "Missing file or donationId" });
      }

      try {
        const url = await uploadPDFToStorage(uploadData.buffer, uploadData.originalname);

        await db.collection("donation").doc(donationId).update({
          recipe: url 
        });

        res.status(200).json({
          success: true,
          url: url
        });
      } catch (err) {
        console.error("🔥 Error updating donation receipt:", err.message);
        res.status(500).json({ error: err.message });
      }
    });

    busboy.end(req.rawBody);
  });
});