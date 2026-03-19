const admin = require("firebase-admin");

async function uploadPDFToStorage(fileBuffer, fileName) {
  try {
    const bucket = admin.storage().bucket();
    const file = bucket.file(`receipts/${fileName}`);

    await file.save(fileBuffer, {
      contentType: "application/pdf",
    });

    const [url] = await file.getSignedUrl({
      action: "read",
      expires: "03-01-2500", 
    });

    return url;
  } catch (err) {
    console.error("Upload error:", err);
    throw err;
  }
}

module.exports = { uploadPDFToStorage };