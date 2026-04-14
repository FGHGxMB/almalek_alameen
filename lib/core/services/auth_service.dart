// lib/core/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // الحصول على المستخدم الحالي
  User? get currentUser => _firebaseAuth.currentUser;

  // تسجيل الدخول بالإيميل وكلمة السر
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}