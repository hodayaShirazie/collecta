<h2 align="center">Overview</h2>


**Collecta** is a Flutter application for managing food donation pickups. It connects **Donors**, **Drivers**, and **Admins** via a Firebase backend.

---

<h2 align="center">Features by Role</h2>


### Donor (Business)
- Sign in with Google
- Report a new donation (products, pickup time windows, business address)
- View and edit existing donations
- Edit business profile


### Driver
- Sign in with Google
- View daily pickup route (with time-window-based route optimization)
- Confirm pickup of each donation stop
- Manage assigned activity zones
- Edit driver profile

### Admin 
- View all drivers and their routes
- View all donations and their statuses
- Manage activity zones
- Inspect donation details
- Impersonate a driver to view their perspective

---

<h2 align="center">Tech Stack</h2>


| Layer | Technology |
|---|---|
| Frontend | Flutter / Dart |
| Auth | Firebase Authentication + Google Sign-In |
| Database | Cloud Firestore |
| File storage | Firebase Storage |
| Backend functions | Firebase Cloud Functions (Node.js) |
| Hosting | Firebase Hosting (two targets: `app`, `admin`) |
| Maps & geocoding | Google Places API |
| Deep linking | `app_links` |
| PDF viewing | Syncfusion Flutter PDF Viewer |
| Data export | `excel` package + `share_plus` |
| Charts | `fl_chart` |
| Geolocation | `geolocator` |

---

<h2 align="center">Supported Platforms</h2>


- Android
- iOS
- Web 
- Windows
- macOS
- Linux

---

<h2 align="center">Project Structure</h2>


```
collecta/
│
├── android/                           # Android platform files
├── ios/                               # iOS platform files
├── web/                               # Web shell (donor/driver app)
├── windows/                           # Windows platform files
├── macos/                             # macOS platform files
├── linux/                             # Linux platform files
│
├── lib/                               # Dart source code
│   ├── main.dart                      # Entry point — donor/driver app
│   ├── main_admin.dart                # Entry point — admin web panel
│   ├── app/
│   │   ├── app.dart                   # Root MaterialApp widget
│   │   ├── routes.dart                # Named route map
│   │   └── theme/
│   ├── config/
│   │   ├── firebase_options.dart      # Per-platform Firebase config (auto-generated)
│   │   └── permissions.dart
│   ├── data/
│   │   ├── models/                    # Dart data classes
│   │   │   ├── donation_model.dart
│   │   │   ├── donor_model.dart
│   │   │   ├── driver_model.dart
│   │   │   ├── organization_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── address_model.dart
│   │   │   ├── activity_zone_model.dart
│   │   │   ├── destination_model.dart
│   │   │   ├── notification_model.dart
│   │   │   └── user_model.dart
│   │   ├── datasources/               # Remote (API) and local (SharedPreferences) sources
│   │   └── repositories/              # Data access layer
│   ├── services/                      # Business logic layer
│   │   ├── donation_service.dart
│   │   ├── donor_service.dart
│   │   ├── driver_service.dart
│   │   ├── organization_service.dart
│   │   ├── user_service.dart
│   │   ├── route_optimization_service.dart
│   │   ├── notification_service.dart
│   │   ├── export_service.dart
│   │   ├── places_service.dart
│   │   ├── activity_zone_service.dart
│   │   ├── admin_service.dart
│   │   ├── org_manager.dart           # Reads orgId from URL / deep link / SharedPreferences
│   │   ├── admin_view_manager.dart    # Admin impersonation state
│   │   └── impersonation_manager.dart
│   └── ui/
│       ├── screens/                   # One file per screen
│       │   ├── entering.dart          # Login / landing screen
│       │   ├── donor_homepage.dart
│       │   ├── driver_homepage.dart
│       │   ├── report_donation.dart
│       │   ├── my_donations.dart
│       │   ├── daily_route_driver.dart
│       │   ├── driver_pickup.dart
│       │   ├── edit_donation.dart
│       │   ├── edit_profile_donor.dart
│       │   ├── edit_profile_driver.dart
│       │   ├── donor_profile_completion.dart
│       │   ├── admin_homepage.dart
│       │   ├── all_donation_admin.dart
│       │   ├── all_driver_admin.dart
│       │   ├── activity_zones_admin.dart
│       │   ├── admin_donation_detail.dart
│       │   └── donor_donation_detail.dart
│       ├── widgets/                   # Reusable UI components
│       ├── guards/                    # AuthGuard for protected routes
│       ├── theme/                     # Per-screen theme styles
│       └── utils/                     # Validators, helpers
│
├── functions/                         # Firebase Cloud Functions (Node.js)
│   ├── index.js                       # Registers all exported functions
│   ├── donations/                     # Donation endpoints
│   │   ├── reportDonation.js
│   │   ├── getDonationById.js
│   │   ├── getAllDonationByOrganization.js
│   │   ├── getMyDonations.js
│   │   ├── getDriverDonationsById.js
│   │   ├── updateDonation.js
│   │   ├── updateDonationReceipt.js
│   │   ├── assignDriverToDonation.js
│   │   ├── cancelDonation.js
│   │   ├── submitPickup.js
│   │   └── stats/                     # Aggregation endpoints
│   │       ├── getDonationsCount.js
│   │       ├── getDonationsCountByMonth.js
│   │       ├── getDonationsPendingCount.js
│   │       ├── getDonationsConfirmedCount.js
│   │       └── getDonationsCanceledCount.js
│   ├── donors/                        # Donor profile endpoints
│   │   ├── getDonorProfile.js
│   │   ├── getDonorProfileById.js
│   │   └── updateDonorProfile.js
│   ├── drivers/                       # Driver profile endpoints
│   │   ├── getDriverProfile.js
│   │   ├── getDriversByOrganization.js
│   │   ├── addDriverByAdmin.js
│   │   ├── updateDriverProfile.js
│   │   └── clearDriverStops.js
│   ├── users/                         # User / auth endpoints
│   │   ├── getMyProfile.js
│   │   ├── getUsers.js
│   │   ├── roles.js
│   │   ├── syncUserWithRole.js
│   │   └── updateUserProfile.js
│   ├── organizations/
│   │   └── getOrganizations.js
│   ├── activityZones/
│   │   ├── createActivityZone.js
│   │   ├── getActivityZones.js
│   │   └── updateActivityZone.js
│   ├── address/
│   │   ├── createAddress.js
│   │   └── updateAddress.js
│   ├── destinations/
│   │   └── updateDestination.js
│   ├── product/
│   │   ├── createProduct.js
│   │   └── productType/
│   │       └── createProductType.js
│   ├── routes/                        # Maps / routing endpoints
│   │   ├── computeRoutes.js           # Route optimization via Google Routes API
│   │   ├── geocodeAddress.js
│   │   ├── placesAutocomplete.js
│   │   ├── placeDetails.js
│   │   └── deleteDriver.js
│   ├── admin/
│   │   └── verifyAdmin.js
│   ├── utils/                         # Shared backend utilities
│   │   ├── cors.js
│   │   ├── resolveUid.js
│   │   ├── validate.js
│   │   └── verifyToken.js
│   └── scripts/
│       └── migrateActivityZones.js    # One-off migration script
│
├── assets/
│   ├── images/logo/                   # Organization and app logos
│   ├── images/category_icons/         # Product category icons
│   └── config/                        # .env file (loaded at runtime)
│
├── public/                            # Firebase Hosting fallback (404 page)
├── firestore.rules                    # Firestore security rules
├── firestore.indexes.json
├── firebase.json                      # Hosting targets + functions config
├── cors.json                          # CORS config for Firebase Storage
├── pubspec.yaml
└── tools/
    └── seed_firestore.dart            # Dev utility: seed initial Firestore data
```

---

<h2 align="center">Getting Started</h2>


### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.10
- Firebase CLI (`npm install -g firebase-tools`)
- A Firebase project with Firestore, Auth, Storage, and Functions enabled
- Google Sign-In configured in the Firebase project

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/hodayaShirazie/collecta.git
cd collecta

# 2. Install Flutter dependencies
flutter pub get

# 3. Add the .env file under assets/config/.env
#    (contact the team for the required keys)

# 4. Install Cloud Functions dependencies
cd functions && npm install && cd ..
```

### Running the App

```bash
# Donor / Driver mobile or desktop
flutter run

# Admin web panel
flutter run -t lib/main_admin.dart -d chrome
```

### Building for Web

```bash
# Donor app
flutter build web --target lib/main.dart --output build/web_app

# Admin panel
flutter build web --target lib/main_admin.dart --output build/web_admin

# Deploy both to Firebase Hosting
firebase deploy --only hosting
```

### Deploy Cloud Functions

```bash
firebase deploy --only functions
```

---

<h2 align="center">Architecture Notes</h2>


- **Multi-tenant**: `OrgManager` reads the `orgId` from the browser URL (web) or a deep link / `SharedPreferences` (mobile). All Firestore queries are scoped to that `orgId`.
- **Admin impersonation**: An admin can view any driver's screen via `AdminViewManager` without logging in as that driver.
- **Two Firebase Hosting targets**: `app` serves the donor/driver web build; `admin` serves the admin panel web build.

---

<h2 align="center">Environment Variables</h2>


The app loads a `.env` file from `assets/config/.env` at runtime using `flutter_dotenv`. Required keys:

| Key | Purpose |
|---|---|
| `GOOGLE_MAPS_API_KEY` | Places autocomplete and geocoding |
| `API_BASE_URL` | Backend Cloud Functions base URL |

---

<h2 align="center"> System Demo</h2>

<p align="center">
  <a href="https://drive.google.com/file/d/1x5LU6s-RB2vycgIOxlZ5rtnyIESxNRaN/view">
    <img src="assets/images/logo/video_README_image.png" width="800" alt="COLLECTA Demo"/>
  </a>
</p>

