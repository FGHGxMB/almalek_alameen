// lib/logic/auth/auth_cubit.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/constants/firestore_keys.dart';
import '../../data/models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _userSub; // مراقب التحديثات الحية

  AuthCubit(this._authRepository) : super(AuthInitial());

  // التحقق من حالة الدخول عند فتح التطبيق
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.checkCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
        _listenToUserUpdates(user.id); // بدء المراقبة
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  // تسجيل الدخول
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email, password);
      emit(AuthAuthenticated(user));
      _listenToUserUpdates(user.id); // بدء المراقبة
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // الاستماع المستمر لتحديثات المستخدم (العدادات والصلاحيات)
  void _listenToUserUpdates(String uid) {
    _userSub?.cancel();
    _userSub = FirebaseFirestore.instance
        .collection(FirestoreKeys.users)
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final updatedUser = UserModel.fromFirestore(doc);
        // إذا قام المدير بإيقاف الحساب، نطرده فوراً
        if (updatedUser.isActive) {
          emit(AuthAuthenticated(updatedUser));
        } else {
          logout();
        }
      }
    });
  }

  // تسجيل الخروج
  Future<void> logout() async {
    emit(AuthLoading());
    _userSub?.cancel(); // إيقاف المراقبة
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _userSub?.cancel();
    return super.close();
  }
}