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
      const {
        donationId,
        businessName,
        businessPhone,
        businessId,
        contactName,
        contactPhone,
        businessAddress,
        pickupTimes,
        products,
      } = req.body;

      if (!donationId) {
        return res.status(400).send({ error: "Missing donationId" });
      }

      if (!isValidString(donationId)) {
        return res.status(400).send({ error: "Invalid donationId" });
      }

      // 🔹 1. עדכון כתובת אם קיימת
      if (businessAddress?.id) {
        const updateAddress = {};
        if (businessAddress.name && typeof businessAddress.name === "string") {
          updateAddress.name = businessAddress.name;
        }
        if (typeof businessAddress.lat === "number") {
          updateAddress.lat = businessAddress.lat;
        }
        if (typeof businessAddress.lng === "number") {
          updateAddress.lng = businessAddress.lng;
        }

        if (Object.keys(updateAddress).length > 0) {
          await db.collection("address").doc(businessAddress.id).update(updateAddress);
        }
      }

      // 🔹 2. בנייה של עדכון התרומה עם השדות שלא ריקים
      const updateDonation = {};
      if (businessName && typeof businessName === "string") {
        updateDonation.businessName = businessName;
      }
      if (businessPhone && typeof businessPhone === "string") {
        updateDonation.businessPhone = businessPhone;
      }
      if (businessId && typeof businessId === "string") {
        updateDonation.crn = businessId;
      }
      if (contactName && typeof contactName === "string") {
        updateDonation.contactName = contactName;
      }
      if (contactPhone && typeof contactPhone === "string") {
        updateDonation.contactPhone = contactPhone;
      }
      if (Array.isArray(pickupTimes) && pickupTimes.length > 0) {
        updateDonation.pickupTimes = pickupTimes;
      }

      // אם יש שדות לעדכון, עדכן את התרומה
      if (Object.keys(updateDonation).length > 0) {
        await db.collection("donation").doc(donationId).update(updateDonation);
      }

      // 🔹 3. עדכון פריטים בתרומה
      if (Array.isArray(products) && products.length > 0) {
        const finalProductIds = [];

        for (const item of products) {
          if (item.id) {
            // פריט קיים — עדכן כמות וסוג מוצר
            const updateProduct = {};
            if (typeof item.quantity === "number") {
              updateProduct.quantity = item.quantity;
            }
            if (item.productTypeId && typeof item.productTypeId === "string") {
              updateProduct.productType = item.productTypeId;
            }
            if (Object.keys(updateProduct).length > 0) {
              await db.collection("product").doc(item.id).update(updateProduct);
            }
            finalProductIds.push(item.id);
          } else if (item.productTypeId) {
            // פריט חדש — צור אותו
            const newRef = await db.collection("product").add({
              productType: item.productTypeId,
              quantity: typeof item.quantity === "number" ? item.quantity : 1,
            });
            finalProductIds.push(newRef.id);
          }
        }

        // עדכן את מערך המוצרים בתרומה
        await db.collection("donation").doc(donationId).update({ products: finalProductIds });
      }

      return res.status(200).send({ status: "success" });

    } catch (e) {
      console.error("Update Error:", e);
      return res.status(500).send({ error: e.message });
    }
  });
};
