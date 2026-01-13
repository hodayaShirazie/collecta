import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // אתחול Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");


   await Firebase.initializeApp(
    options: FirebaseOptions(
       apiKey: dotenv.env['FIREBASE_API_KEY']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
    ),
  );

  final db = FirebaseFirestore.instance;

  // -------------------
  // Organization
  // -------------------
  final orgRef = db.collection('organization').doc(); // ID אוטומטי
  await orgRef.set({
    'id': orgRef.id,
    'name': 'Latet Branch 1',
    'admin_id': '', // אפשר להשאיר ריק או למלא אחר כך
    'created_at': FieldValue.serverTimestamp(),
    'logo': 'https://example.com/logo.png',
  });

  // -------------------
  // User
  // -------------------
  final userRef = db.collection('user').doc();
  await userRef.set({
    'id': userRef.id,
    'name': 'Hodaya',
    'mail': 'hodaya@example.com',
    'img': 'https://example.com/profile.png',
  });

  // -------------------
  // Admin
  // -------------------
  final adminRef = db.collection('admin').doc();
  await adminRef.set({
    'id': adminRef.id,
    'user_id': userRef.id,
    'organization_id': orgRef.id,
    'role': 'SUPER_ADMIN',
  });

  // -------------------
  // Donor
  // -------------------
  final donorRef = db.collection('donor').doc();
  await donorRef.set({
    'id': donorRef.id,
    'organization_id': orgRef.id,
    'businessPhone': '050-1234567',
    'businessName': 'Bakery Shop',
    'businessAddress_id': '', // אפשר למלא לאחר מכן
    'crn': '123456789',
    'coins': 50,
    'contactName': 'Shira',
    'contactPhone': '050-7654321',
    'created_at': FieldValue.serverTimestamp(),
    'last_login': FieldValue.serverTimestamp(),
  });

  // -------------------
  // Driver
  // -------------------
  final driverRef = db.collection('driver').doc();
  await driverRef.set({
    'id': driverRef.id,
    'organization_id': orgRef.id,
    'phone': '050-0000000',
    'area': 'Tel Aviv',
    'destination': [],
    'stops': [],
    'created_at': FieldValue.serverTimestamp(),
  });

  // -------------------
  // Destination
  // -------------------
  final destRef = db.collection('destination').doc();
  await destRef.set({
    'id': destRef.id,
    'organization_id': orgRef.id,
    'name': 'Community Center',
    'day': 'Monday',
    'address_id': '', // אפשר למלא לאחר מכן
  });

  // -------------------
  // Product
  // -------------------
  final productRef = db.collection('product').doc();
  await productRef.set({
    'id': productRef.id,
    'productTypes': 'DAIRY',
    'quantity': 10,
  });

  // -------------------
  // TimeWindow
  // -------------------
  final timeRef = db.collection('timeWindow').doc();
  await timeRef.set({
    'id': timeRef.id,
    'pickup_available_from': '10:00',
    'pickup_available_until': '12:00',
  });

  // -------------------
  // Address
  // -------------------
  final addressRef = db.collection('address').doc();
  await addressRef.set({
    'id': addressRef.id,
    'name': 'Bialik St. 10, Tel Aviv',
    'lat': 32.0853,
    'lng': 34.7818,
  });

  // -------------------
  // ProductTypes
  // -------------------
  final dairyRef = db.collection('productType').doc();
  await dairyRef.set({
    'id': dairyRef.id,
    'name': 'Dairy',
  });

  final pastriesRef = db.collection('productType').doc();
  await pastriesRef.set({
    'id': pastriesRef.id,
    'name': 'Pastries',
  });

  // -------------------
  // OrganizationProductTypes
  // -------------------
  final orgProdDairyRef = db.collection('organizationProductType').doc();
  await orgProdDairyRef.set({
    'organization_id': orgRef.id,
    'type_id': dairyRef.id,
  });

  final orgProdPastriesRef = db.collection('organizationProductType').doc();
  await orgProdPastriesRef.set({
    'organization_id': orgRef.id,
    'type_id': pastriesRef.id,
  });

  // -------------------
  // Donation
  // -------------------
  final donationRef = db.collection('donation').doc();
  await donationRef.set({
    'id': donationRef.id,
    'organization_id': orgRef.id,
    'donor_id': donorRef.id,
    'contactName': 'Shira',
    'contactPhone': '050-7654321',
    'pickupTimes': [timeRef.id],
    'status': 'PENDING',
    'driver_id': driverRef.id,
    'receipt': '',
    'product': [productRef.id],
    'cancelingReason': '',
    'address_id': addressRef.id,
    'created_at': FieldValue.serverTimestamp(),
  });

  print('Seeding done!');
}
