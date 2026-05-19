const cors = require("cors");
const allowedOrigins = [
  "https://collecta-125aa.web.app",
  "https://collecta-125aa.firebaseapp.com",
  "https://collecta-125aa-control.web.app",
];
module.exports = cors({
  origin: (origin, callback) => {
    const isLocalhost = !origin || /^http:\/\/localhost(:\d+)?$/.test(origin);
    if (isLocalhost || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
});


