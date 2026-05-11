// lib/logic/settings/basic_info_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';

abstract class BasicInfoState {}
class BasicInfoLoading extends BasicInfoState {}
class BasicInfoLoaded extends BasicInfoState {
  final Map<String, dynamic> configData;
  BasicInfoLoaded(this.configData);
}
class BasicInfoError extends BasicInfoState {
  final String message;
  BasicInfoError(this.message);
}
class BasicInfoSuccess extends BasicInfoState {}

class BasicInfoCubit extends Cubit<BasicInfoState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BasicInfoCubit() : super(BasicInfoLoading()) {
    loadData();
  }

  Future<void> loadData() async {
    emit(BasicInfoLoading());
    try {
      final doc = await _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc).get();
      if (doc.exists) {
        emit(BasicInfoLoaded(doc.data() ?? {}));
      } else {
        emit(BasicInfoError('ملف الإعدادات غير موجود في السيرفر'));
      }
    } catch (e) {
      emit(BasicInfoError('خطأ في جلب البيانات: $e'));
    }
  }

  Future<void> updateData(Map<String, dynamic> newData) async {
    emit(BasicInfoLoading());
    try {
      // إزالة await ليتم الحفظ في الخلفية فوراً وتغلق الشاشة
      _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc).set(newData, SetOptions(merge: true));

      emit(BasicInfoSuccess());
      // لا نستدعي loadData() هنا لكي لا نؤخر الإغلاق
    } catch (e) {
      emit(BasicInfoError('خطأ أثناء الحفظ: $e'));
      loadData();
    }
  }
}