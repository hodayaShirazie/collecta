import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    final snapshot = await _db.collection(collection).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
