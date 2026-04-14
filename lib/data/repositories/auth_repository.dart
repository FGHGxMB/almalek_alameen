// lib/data/repositories/auth_repository.dart

import '../models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  // تسجيل الدخول والتحقق من حساب المستخدم في Firestore
  Future<UserModel> login(String email, String password) async {
    try {
      final UserCredential credential = await _authService.signInWithEmailAndPassword(email, password);
      final User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('فشل في استرداد بيانات المستخدم من Auth.');
      }

      final doc = await _firestoreService.getUserDocument(firebaseUser.uid);

      if (!doc.exists) {
        await _authService.signOut();
        throw Exception('لا يوجد حساب مرتبط بهذا البريد في قاعدة البيانات. تواصل مع الإدارة.');
      }

      final userModel = UserModel.fromFirestore(doc);

      if (!userModel.isActive) {
        await _authService.signOut();
        throw Exception('حسابك موقوف حالياً. يرجى مراجعة الإدارة.');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة.');
      }
      throw Exception(e.message ?? 'حدث خطأ أثناء تسجيل الدخول.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  // التحقق المبدئي إذا كان المستخدم مسجل دخول بالفعل
  Future<UserModel?> checkCurrentUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      try {
        final doc = await _firestoreService.getUserDocument(firebaseUser.uid);
        if (doc.exists) {
          final userModel = UserModel.fromFirestore(doc);
          if (userModel.isActive) {
            return userModel;
          } else {
            await _authService.signOut();
          }
        }
      } catch (e) {
        // في حالة الـ Offline وعدم توفر بيانات الكاش سيتخطى الخطأ بصمت
        return null;
      }
    }
    return null;
  }
}