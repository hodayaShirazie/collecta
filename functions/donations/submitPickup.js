const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const { isValidString } = require("../utils/validate");
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

            if (!isValidString(donationId)) {
                return res.status(400).send({ error: "Invalid input parameters" });
            }

            const { donorId } = req.body;

            const batch = db.batch();

            let totalCoins = 0;

            for (const item of products) {
                const productRef = db.collection("product").doc(item.productId);

                if (item.isPickedUp === false) {
                    batch.delete(productRef);
                    if (item.productTypeId && item.isOther === true) {
                        const typeRef = db.collection("productType").doc(item.productTypeId);
                        batch.delete(typeRef);
                    }
                } else {

                    batch.update(productRef, {
                        quantity: item.collectedQuantity
                    });

                    if (item.productTypeId && item.newDescription) {
                        const typeRef = db.collection("productType").doc(item.productTypeId);
                        batch.set(typeRef, {
                            description: item.newDescription
                        }, { merge: true });
                    }

                    totalCoins += (item.collectedQuantity || 0) * 5;
                }
            }

            const donationRef = db.collection("donation").doc(donationId);
            batch.update(donationRef, {
                status: "collected",
                collected_at: admin.firestore.FieldValue.serverTimestamp()
            });

            if (donorId && totalCoins > 0) {
                const donorRef = db.collection("donor").doc(donorId);
                batch.update(donorRef, {
                    coins: admin.firestore.FieldValue.increment(totalCoins)
                });
            }

            await batch.commit();
            return res.status(200).send({ status: "success" });

        } catch (e) {
            return res.status(500).send({ error: e.message });
        }
    });
};