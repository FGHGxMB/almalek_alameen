import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_state.dart';
import '../../core/constants/firestore_keys.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _configSub;

  SettingsCubit() : super(SettingsLoading()) {
    _listenToAppConfig();
  }

  void _listenToAppConfig() {
    _configSub = _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc)
        .snapshots(includeMetadataChanges: true).listen((doc) {
      if (doc.exists) {
        final rate = (doc.data()?['currency_rate'] ?? 1.0).toDouble();
        final isSynced = !doc.metadata.hasPendingWrites; // السحر الخاص بالأوفلاين
        emit(SettingsLoaded(rate, isSynced));
      }
    });
  }

  Future<void> updateCurrencyRate(double newRate) async {
    try {
      await _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc).update({
        'currency_rate': newRate,
      });
      // لا نُصدر حالة Success هنا لأن الـ Stream سيحدث الـ UI تلقائياً
    } catch (e) {
      emit(SettingsError('حدث خطأ أثناء حفظ سعر الدولار: $e'));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final currentState = state; // حفظ الحالة للرجوع إليها
    emit(SettingsLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');
      await user.updatePassword(newPassword);
      emit(SettingsSuccess('تم تغيير كلمة المرور بنجاح'));
      if (currentState is SettingsLoaded) emit(currentState); // إرجاع الواجهة
    } on FirebaseAuthException catch (e) {
      emit(SettingsError(e.message ?? 'حدث خطأ في المصادقة'));
      if (currentState is SettingsLoaded) emit(currentState);
    } catch (e) {
      emit(SettingsError('حدث خطأ: $e'));
      if (currentState is SettingsLoaded) emit(currentState);
    }
  }

  @override
  Future<void> close() {
    _configSub?.cancel();
    return super.close();
  }
}