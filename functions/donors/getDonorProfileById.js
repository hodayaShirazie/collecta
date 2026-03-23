// functions/donors/getDonorProfileById.js
const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");

const db = admin.firestore();

module.exports = async (req, res) => {
    corsHandler(req, res, async () => {
        const firebaseUser = await verifyFirebaseToken(req, res);
        if (!firebaseUser) return;

        try {
            const donorId = req.query.donorId;
            if (!donorId) return res.status(400).send({ error: "Missing donor ID" });

            // 1. שליפת נתוני המשתמש הכלליים
            const userSnap = await db.collection("user").doc(donorId).get();
            if (!userSnap.exists) return res.status(404).send({ error: "User not found" });

            // 2. שליפת נתוני התורם
            const donorSnap = await db.collection("donor").doc(donorId).get();
            if (!donorSnap.exists) return res.status(404).send({ error: "Donor info not found" });

            const donorData = donorSnap.data();
            const addressId = donorData.businessAddress;

            // 3. שליפת כתובת העסק
            let addressData = null;
            if (addressId) {
                const addressSnap = await db.collection("address").doc(addressId).get();
                if (addressSnap.exists) {
                    addressData = { id: addressSnap.id, ...addressSnap.data() };
                }
            }

            const normalize = (ts) => ts?.toDate ? ts.toDate().toISOString() : ts;

            return res.status(200).send({
                user: {
                    uid: donorId,
                    ...userSnap.data(),
                    created_at: normalize(userSnap.data().created_at),
                    last_login: normalize(userSnap.data().last_login),
                },
                role: donorData,
                address: addressData,
            });
        } catch (e) {
            console.error("Error fetching donor profile:", e);
            return res.status(500).send({ error: e.message });
        }
    });
};