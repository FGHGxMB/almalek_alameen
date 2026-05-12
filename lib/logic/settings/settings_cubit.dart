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

  StreamSubscription? _productsSub;

  void _listenToAppConfig() {
    bool configSynced = true;
    bool prodSynced = true;
    double rate = 1.0;

    _configSub = _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc).snapshots(includeMetadataChanges: true).listen((doc) {
      if (doc.exists) {
        rate = (doc.data()?['currency_rate'] ?? 1.0).toDouble();
        configSynced = !doc.metadata.hasPendingWrites;
        emit(SettingsLoaded(rate, configSynced, prodSynced));
      }
    });

    _productsSub = _firestore.collection(FirestoreKeys.products).snapshots(includeMetadataChanges: true).listen((snap) {
      prodSynced = !snap.metadata.hasPendingWrites;
      if (state is SettingsLoaded) emit(SettingsLoaded(rate, configSynced, prodSynced));
    });
  }

  Future<void> updateCurrencyRate(double newRate, String userName) async {
    try {
      final batch = _firestore.batch();

      // 1. تحديث السعر في الإعدادات
      final configRef = _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc);
      batch.update(configRef, {'currency_rate': newRate});

      // 2. تسجيل الحركة في سجل التاريخ
      final historyRef = _firestore.collection(FirestoreKeys.currencyHistory).doc();
      batch.set(historyRef, {
        'rate': newRate,
        'user_name': userName,
        'date': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // 3. تنظيف السجل (الاحتفاظ بآخر 50 تغييراً فقط)
      final snap = await _firestore.collection(FirestoreKeys.currencyHistory).orderBy('date', descending: true).get();
      if (snap.docs.length > 50) {
        final batchDelete = _firestore.batch();
        for (int i = 50; i < snap.docs.length; i++) {
          batchDelete.delete(snap.docs[i].reference);
        }
        await batchDelete.commit();
      }
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
    _productsSub?.cancel();
    return super.close();
  }
}