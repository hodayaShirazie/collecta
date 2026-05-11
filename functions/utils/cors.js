const cors = require("cors");
const allowedOrigins = [
  "https://collecta-125aa.web.app",
  "https://collecta-125aa.firebaseapp.com",
];
module.exports = cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
});


