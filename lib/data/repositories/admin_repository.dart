// lib/data/repositories/admin_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';
import '../models/user_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: Firebase.app().options,
    );

    try {
      UserCredential credential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;

      await _firestore.collection(FirestoreKeys.users).doc(uid).set({
        FirestoreKeys.email: email,
        FirestoreKeys.isActive: true,
        ...userData,
      });
    } finally {
      await secondaryApp.delete();
    }
  }

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

  // حذف المستخدم نهائياً من قاعدة البيانات
  Future<void> deleteUser(String uid) async {
    await _firestore.collection(FirestoreKeys.users).doc(uid).delete();
  }

  // // --- إرسال رابط تغيير كلمة السر ---
  // Future<void> sendPasswordResetEmail(String email) async {
  //   await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  // }

  // --- فحص وجود حركات أو زبائن قبل الحذف ---
  Future<bool> hasUserRecords(String uid) async {
    const GetOptions serverOnly = GetOptions(source: Source.server);

    try {
      final custSnap = await _firestore.collection(FirestoreKeys.customers).where(FirestoreKeys.delegateId, isEqualTo: uid).limit(1).get(serverOnly);
      if (custSnap.docs.isNotEmpty) return true;

      final invSnap = await _firestore.collection(FirestoreKeys.invoices).where(FirestoreKeys.delegateId, isEqualTo: uid).limit(1).get(serverOnly);
      if (invSnap.docs.isNotEmpty) return true;

      final retSnap = await _firestore.collection(FirestoreKeys.returns).where(FirestoreKeys.delegateId, isEqualTo: uid).limit(1).get(serverOnly);
      if (retSnap.docs.isNotEmpty) return true;

      final recSnap = await _firestore.collection(FirestoreKeys.receipts).where(FirestoreKeys.delegateId, isEqualTo: uid).limit(1).get(serverOnly);
      if (recSnap.docs.isNotEmpty) return true;

      return false;
    } catch (e) {
      // في حال عدم وجود إنترنت نعتبر أن لديه بيانات كإجراء وقائي لمنع الحذف بالخطأ
      throw Exception('يرجى الاتصال بالإنترنت للتحقق من بيانات المستخدم قبل حذفه.');
    }
  }
}