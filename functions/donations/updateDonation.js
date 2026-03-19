
// const admin = require("firebase-admin");
// const corsHandler = require("../utils/cors");
// const verifyFirebaseToken = require("../utils/verifyToken");

// const db = admin.firestore();

// module.exports = async (req, res) => {
//   corsHandler(req, res, async () => {
//     const firebaseUser = await verifyFirebaseToken(req, res);
//     if (!firebaseUser) return;

//     try {
//       const {
//         donationId,
//         contactName,
//         contactPhone,
//         products,
//         pickupTimes,
//         businessAddress,
//         businessName,
//         businessPhone,
//         businessId,
//         donatedItems
//       } = req.body;

//       if (!donationId) {
//         return res.status(400).send({ error: "Missing donationId" });
//       }

//       // 🔹 1. עדכון כתובת
//       if (businessAddress?.id) {
//         await db.collection("address").doc(businessAddress.id).update({
//           name: businessAddress.name,
//           lat: Number(businessAddress.lat),
//           lng: Number(businessAddress.lng),
//         });
//       }

//       // 🔹 2. עדכון מסמך Donation
//       await db.collection("donation").doc(donationId).update({
//         contactName,
//         contactPhone,
//         businessName,
//         businessPhone,
//         businessId,
//         pickupTimes,
//         products: donatedItems.map(item => item.id), // שמירת IDs בלבד
//       });

//       // 🔹 3. עדכון פריטים
//       for (const item of donatedItems || []) {
//         if (!item["id"]) continue;

//         const productRef = db.collection("product").doc(item["id"]);
//         const productTypeRef = db.collection("productType").doc(item["productType"]);

//         // אם זה "אחר" נעדכן את ה-description בטבלת ProductType
//         if (item["name"] === "אחר" && item["description"]) {
//           await productTypeRef.update({
//             description: item["description"]
//           });
//         }

//         // עדכון הכמות וה-ID בטבלת Product
//         await productRef.update({
//           quantity: Number(item["quantity"]),
//           productType: item["productType"],
//           description: item["description"] || ""
//         });
//       }

//       return res.status(200).send({ status: "success" });

//     } catch (e) {
//       return res.status(500).send({ error: e.message });
//     }
//   });
// };



const functions = require("firebase-functions");
const admin = require("firebase-admin"); 
const { uploadPDFToStorage } = require("./utils/uploadReceiptHelper");
const Busboy = require("busboy");
const cors = require("../utils/cors"); 

const db = admin.firestore();

module.exports = functions.https.onRequest((req, res) => {
  return cors(req, res, async () => {

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
        // 1. העלאה ל-Storage
        const url = await uploadPDFToStorage(uploadData.buffer, uploadData.originalname);
        
        // 2. עדכון השדה "recipe" ב-Firestore
        // חשוב: וודאי ששם הקולקשן הוא "donation" (כמו בדוגמה הקודמת ששלחת)
        await db.collection("donation").doc(donationId).update({
          recipe: url // <--- כאן שיניתי ל-recipe לפי מה שכתבת
        });

        res.status(200).json({
          success: true,
          url: url
        });
      } catch (err) {
        console.error("Update Error:", err);
        res.status(500).json({ error: err.message });
      }
    });

    busboy.end(req.rawBody);
  });
});