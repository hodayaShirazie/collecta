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

const admin = require("firebase-admin");
const { onRequest } = require("firebase-functions/v2/https");
const { defineJsonSecret } = require("firebase-functions/params");

const config = defineJsonSecret("FUNCTIONS_CONFIG_EXPORT");

admin.initializeApp();

exports.getUsers = onRequest(
  require("./users/getUsers")
);

exports.getOrganizations = onRequest(
  require("./organizations/getOrganizations")
);

exports.syncUserWithRole = onRequest(
  require("./users/syncUserWithRole")
);

exports.getMyProfile = onRequest(
  require("./users/getMyProfile")
);

exports.getDonorProfile = onRequest(
  require("./donors/getDonorProfile")
);

exports.getDriverProfile = onRequest(
  require("./drivers/getDriverProfile")
);

exports.updateDonorProfile = onRequest(
  require("./donors/updateDonorProfile")
);

exports.updateDriverProfile = onRequest(
  require("./drivers/updateDriverProfile")
);

exports.updateAddress = onRequest(
  require("./address/updateAddress")
);

exports.updateDestination = onRequest(
  require("./destinations/updateDestination")
);

exports.reportDonation = onRequest(
  require("./donations/reportDonation")
);

exports.updateUserProfile = onRequest(
  require("./users/updateUserProfile")
);

exports.createAddress = onRequest(
  require("./address/createAddress")
);

exports.createProductType = onRequest(
  require("./product/productType/createProductType")
);

exports.createProduct = onRequest(
  require("./product/createProduct")
);

exports.getMyDonations = onRequest(
  require("./donations/getMyDonations")
);

exports.getDonationById = onRequest(
  require("./donations/getDonationById")
);

exports.getAllDonationsByOrganization = onRequest(
  require("./donations/getAllDonationByOrganization")
);

exports.getDriversByOrganization = onRequest(
  require("./drivers/getDriversByOrganization")
);

exports.getDonationsCount = onRequest(
  require("./donations/stats/getDonationsCount")
);

exports.getDonationsPendingCount = onRequest(
  require("./donations/stats/getDonationsPendingCount")
);

exports.getDonationsCountByMonth = onRequest(
  require("./donations/stats/getDonationsCountByMonth")
);

exports.getDonationsCanceledCount = onRequest(
  require("./donations/stats/getDonationsCanceledCount")
);

exports.getDonationsConfirmedCount = onRequest(
  require("./donations/stats/getDonationsConfirmedCount")
);

const placesAutocomplete = require("./routes/placesAutocomplete").placesAutocomplete;

exports.placesAutocomplete = onRequest(
  { secrets: [config] },
  (req, res) => placesAutocomplete(req, res)
);

const placeDetails = require("./routes/placeDetails");

exports.placeDetails = onRequest(
  { secrets: [config] },
  (req, res) => placeDetails(req, res)
);

exports.updateDonation = onRequest(
  require("./donations/updateDonation")
);

exports.cancelDonation = onRequest(
  require("./donations/cancelDonation")
);

exports.updateDonationReceipt = require("./donations/updateDonationReceipt");

exports.getDriverDonationsById = onRequest(
  require("./donations/getDriverDonationsById")
);

exports.getDonorProfileById = onRequest(
  require("./donors/getDonorProfileById")
);

exports.submitPickup = onRequest(
  require("./donations/submitPickup")
);

exports.createActivityZone = onRequest(
  require("./activityZones/createActivityZone")
);

exports.updateActivityZone = onRequest(
  require("./activityZones/updateActivityZone")
);

exports.getActivityZones = onRequest(
  require("./activityZones/getActivityZones")
);

exports.addDriverByAdmin = onRequest(
  require("./drivers/addDriverByAdmin")
);

const geocodeAddress = require("./routes/geocodeAddress").geocodeAddress;

exports.geocodeAddress = onRequest(
  (req, res) => geocodeAddress(req, res)
);

exports.computeRoutes = onRequest(
  require("./routes/computeRoutes")
);