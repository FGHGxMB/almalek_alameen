// lib/core/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_keys.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تفعيل التخزين المؤقت (Offline Persistence)
  Future<void> enableNetworkAndPersistence() async {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // جلب وثيقة المستخدم كـ DocumentSnapshot
  Future<DocumentSnapshot> getUserDocument(String uid) async {
    return await _firestore.collection(FirestoreKeys.users).doc(uid).get();
  }
}