// lib/data/repositories/admin_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';
import '../models/user_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إنشاء مستخدم جديد بطريقة آمنة لا تُخرج المدير من التطبيق
  Future<void> createUser({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    // تهيئة تطبيق فايربيز مؤقت لإنشاء الحساب
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: Firebase.app().options,
    );

    try {
      // إنشاء الحساب في التطبيق المؤقت
      UserCredential credential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;

      // حفظ بيانات المستخدم في Firestore
      await _firestore.collection(FirestoreKeys.users).doc(uid).set({
        FirestoreKeys.email: email,
        FirestoreKeys.isActive: true,
        ...userData,
      });
    } finally {
      // إغلاق التطبيق المؤقت لكي لا يستهلك الذاكرة
      await secondaryApp.delete();
    }
  }

  // تعديل بيانات المستخدم في Firestore
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(FirestoreKeys.users).doc(uid).update(data);
  }

  Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection(FirestoreKeys.users)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList());
  }
}