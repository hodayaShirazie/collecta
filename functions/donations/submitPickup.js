// const admin = require("firebase-admin");
// const corsHandler = require("../utils/cors");
// const verifyFirebaseToken = require("../utils/verifyToken");
// const db = admin.firestore();

// module.exports = async (req, res) => {
//     corsHandler(req, res, async () => {
//         const firebaseUser = await verifyFirebaseToken(req, res);
//         if (!firebaseUser) return res.status(401).send({ error: "Unauthorized" });

//         try {
//             const { donationId, products } = req.body;

//             if (!donationId || !products || !Array.isArray(products)) {
//                 return res.status(400).send({ error: "Missing donationId or products array" });
//             }

//             const batch = db.batch();

//             for (const item of products) {
//                 // 1. עדכון כמויות בלבד בטבלת product (ללא סטטוס)
//                 const productRef = db.collection("product").doc(item.productId);
//                 batch.update(productRef, {
//                     quantity: item.collectedQuantity
//                 });

//                 // 2. עדכון התיאור בטבלת productType אם נשלח תיאור חדש
//                 if (item.productTypeId && item.newDescription) {
//                     const typeRef = db.collection("productType").doc(item.productTypeId);
//                     batch.set(typeRef, {
//                         description: item.newDescription
//                     }, { merge: true });
//                 }
//             }

//             // 3. עדכון סטטוס התרומה הכללית בטבלת donation
//             const donationRef = db.collection("donation").doc(donationId);
//             batch.update(donationRef, {
//                 status: "collected",
//                 collected_at: admin.firestore.FieldValue.serverTimestamp()
//             });

//             await batch.commit();
//             return res.status(200).send({ status: "success" });

//         } catch (e) {
//             return res.status(500).send({ error: e.message });
//         }
//     });
// };





const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const db = admin.firestore();

module.exports = async (req, res) => {
    corsHandler(req, res, async () => {
        const firebaseUser = await verifyFirebaseToken(req, res);
        if (!firebaseUser) return res.status(401).send({ error: "Unauthorized" });

        try {
            const { donationId, products } = req.body;

            if (!donationId || !products || !Array.isArray(products)) {
                return res.status(400).send({ error: "Missing donationId or products array" });
            }

            const batch = db.batch();

            for (const item of products) {
                const productRef = db.collection("product").doc(item.productId);

                if (item.isPickedUp === false) {
                    // --- לוגיקת מחיקה במידה ובוטל ---
                    
                    // 1. מחיקה מטבלת product
                    batch.delete(productRef);

                    // 2. אם זה מוצר מסוג "אחר", מוחקים גם את ה-productType שלו
                    // (אנחנו מזהים שזה "אחר" אם נשלח תיאור או לפי זיהוי ב-Flutter)
                    if (item.productTypeId && item.isOther === true) {
                        const typeRef = db.collection("productType").doc(item.productTypeId);
                        batch.delete(typeRef);
                    }
                } else {
                    // --- לוגיקת עדכון רגילה במידה ואושר ---
                    
                    batch.update(productRef, {
                        quantity: item.collectedQuantity
                    });

                    if (item.productTypeId && item.newDescription) {
                        const typeRef = db.collection("productType").doc(item.productTypeId);
                        batch.set(typeRef, {
                            description: item.newDescription
                        }, { merge: true });
                    }
                }
            }

            // עדכון סטטוס התרומה הכללית בטבלת donation
            const donationRef = db.collection("donation").doc(donationId);
            batch.update(donationRef, {
                status: "collected",
                collected_at: admin.firestore.FieldValue.serverTimestamp()
            });

            await batch.commit();
            return res.status(200).send({ status: "success" });

        } catch (e) {
            return res.status(500).send({ error: e.message });
        }
    });
};