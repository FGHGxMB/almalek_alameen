// lib/logic/settings/settings_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_state.dart';
import '../../core/constants/firestore_keys.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SettingsCubit() : super(SettingsInitial());

  // تغيير كلمة المرور للمستخدم الحالي
  Future<void> updatePassword(String newPassword) async {
    emit(SettingsLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      await user.updatePassword(newPassword);
      emit(SettingsSuccess('تم تغيير كلمة المرور بنجاح'));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        emit(SettingsError('هذه العملية حساسة وتتطلب تسجيل الخروج والدخول مجدداً أولاً.'));
      } else {
        emit(SettingsError(e.message ?? 'حدث خطأ في المصادقة'));
      }
    } catch (e) {
      emit(SettingsError('حدث خطأ أثناء تغيير كلمة المرور: $e'));
    }
  }
}