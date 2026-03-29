
const admin = require("firebase-admin");
const corsHandler = require("../utils/cors");
const verifyFirebaseToken = require("../utils/verifyToken");
const { isValidString } = require("../utils/validate");

const db = admin.firestore();

module.exports = async (req, res) => {
  corsHandler(req, res, async () => {

    if (req.method === "OPTIONS") {
      return res.status(204).send("");
    }

    const firebaseUser = await verifyFirebaseToken(req, res);
    if (!firebaseUser) return;

    const organizationId = req.query.organizationId;

    if (!organizationId) {
      return res.status(400).send({ error: "organizationId is required" });
    }

    if (!isValidString(organizationId)) {
      return res.status(400).send({ error: "Invalid input parameters" });
    }

    try {

      const usersSnap = await db
        .collection("user")
        .where("organization_id", "==", organizationId)
        .get();

      if (usersSnap.empty) {
        return res.status(200).send([]);
      }


      const usersMap = {};
      usersSnap.docs.forEach(doc => {
        const data = doc.data();
        usersMap[data.uid] = data;
      });

      const uids = Object.keys(usersMap);


      const chunkSize = 30;
      const driverDocs = [];

      for (let i = 0; i < uids.length; i += chunkSize) {
        const chunk = uids.slice(i, i + chunkSize);

        const driversSnap = await db
          .collection("driver")
          .where("id", "in", chunk)
          .get();

        driverDocs.push(...driversSnap.docs);
      }

      const result = driverDocs.map(doc => {
        const driverData = doc.data();
        const uid = driverData.id;
        const rawUser = usersMap[uid] || {};

        const user = {
          uid: rawUser.uid,
          name: rawUser.name,
          mail: rawUser.mail,
          img: rawUser.img,
          organization_id: rawUser.organization_id || "",
          created_at: rawUser.created_at
            ? rawUser.created_at.toDate().toISOString()
            : null,
          last_login: rawUser.last_login
            ? rawUser.last_login.toDate().toISOString()
            : null,
        };

        return {
          user: user,
          role: {
            id: driverData.id,
            phone: driverData.phone || "",
            area: driverData.area || "",
            destination: driverData.destination || [],
            stops: driverData.stops || [],
          }
        };
      });

      return res.status(200).send(result);

    } catch (error) {
      console.error("❌ Error in getDriversByOrganization:", error);
      return res.status(500).send({ error: error.message });
    }
  });
};
