// /**
//  * Import function triggers from their respective submodules:
//  *
//  * const {onCall} = require("firebase-functions/v2/https");
//  * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
//  *
//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
//  */

// const {setGlobalOptions} = require("firebase-functions");
// const {onRequest} = require("firebase-functions/https");
// const logger = require("firebase-functions/logger");

// // For cost control, you can set the maximum number of containers that can be
// // running at the same time. This helps mitigate the impact of unexpected
// // traffic spikes by instead downgrading performance. This limit is a
// // per-function limit. You can override the limit for each function using the
// // `maxInstances` option in the function's options, e.g.
// // `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// // NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// // functions should each use functions.runWith({ maxInstances: 10 }) instead.
// // In the v1 API, each function can only serve one request per container, so
// // this will be the maximum concurrent request count.
// setGlobalOptions({ maxInstances: 10 });

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// // exports.helloWorld = onRequest((request, response) => {
// //   logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { onRequest } = require("firebase-functions/v2/https");
const { defineJsonSecret } = require("firebase-functions/params");

const config = defineJsonSecret("FUNCTIONS_CONFIG_EXPORT");

admin.initializeApp();

exports.getUsers = functions.https.onRequest(
  require("./users/getUsers")
);

exports.getOrganizations = functions.https.onRequest(
  require("./organizations/getOrganizations")
);

exports.syncUserWithRole = functions.https.onRequest(
  require("./users/syncUserWithRole")
);

exports.getMyProfile = functions.https.onRequest(
  require("./users/getMyProfile")
);

exports.getDonorProfile = functions.https.onRequest(
  require("./donors/getDonorProfile")
);

exports.getDriverProfile = functions.https.onRequest(
  require("./drivers/getDriverProfile")
);

exports.updateDonorProfile = functions.https.onRequest(
  require("./donors/updateDonorProfile")
);

exports.updateDriverProfile = functions.https.onRequest(
  require("./drivers/updateDriverProfile")
);

exports.updateAddress  = functions.https.onRequest(
  require("./address/updateAddress")
);

exports.updateDestination = functions.https.onRequest(
  require("./destinations/updateDestination")
);

exports.reportDonation = functions.https.onRequest(
  require("./donations/reportDonation")
);

exports.updateUserProfile = functions.https.onRequest(
  require("./users/updateUserProfile")
);

exports.createAddress = functions.https.onRequest(
  require("./address/createAddress")
);

exports.createProductType = functions.https.onRequest(
  require("./product/productType/createProductType")
);

exports.createProduct = functions.https.onRequest(
  require("./product/createProduct")
);

exports.getMyDonations = onRequest(
  require("./donations/getMyDonations")
);  

exports.getAllDonationsByOrganization = functions.https.onRequest(
  require("./donations/getAllDonationByOrganization")
);

exports.getDriversByOrganization = functions.https.onRequest(
  require("./drivers/getDriversByOrganization")
);


exports.getDonationsCount = functions.https.onRequest(
  require("./donations/stats/getDonationsCount")
);

exports.getDonationsPendingCount = functions.https.onRequest(
  require("./donations/stats/getDonationsPendingCount")
);

exports.getDonationsCountByMonth = functions.https.onRequest(
  require("./donations/stats/getDonationsCountByMonth")
);

exports.getDonationsCanceledCount = functions.https.onRequest(
  require("./donations/stats/getDonationsCanceledCount")
);  


exports.getDonationsConfirmedCount = functions.https.onRequest(
  require("./donations/stats/getDonationsConfirmedCount")
);

const placesAutocomplete = require("./routes/placesAutocomplete").placesAutocomplete;

exports.placesAutocomplete = onRequest(
  { secrets: [config] },
  (req, res) => placesAutocomplete(req, res)
);


const placeDetails = require("./routes/placeDetails");
const e = require("cors");

exports.placeDetails = onRequest(
  { secrets: [config] },
  (req, res) => placeDetails(req, res)
);