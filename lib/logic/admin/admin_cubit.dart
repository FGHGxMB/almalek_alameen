// lib/logic/admin/admin_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_state.dart';
import '../../data/repositories/admin_repository.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;
  StreamSubscription? _sub;

  AdminCubit(this._repository) : super(AdminLoading()) {
    _sub = _repository.getUsersStream().listen(
          (users) => emit(AdminLoaded(users)),
      onError: (e) => emit(AdminError('خطأ في جلب المستخدمين: $e')),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _repository.deleteUser(uid);
      // لا حاجة لعمل emit لأن الـ Stream سيحدث القائمة تلقائياً بحذف المستخدم
    } catch (e) {
      emit(AdminError('خطأ أثناء الحذف: $e'));
    }
  }

  // دالة فحص السجلات
  Future<bool> checkUserRecords(String uid) async {
    return await _repository.hasUserRecords(uid);
  }

  // // دالة إعادة تعيين كلمة المرور
  // Future<void> sendPasswordReset(String email) async {
  //   try {
  //     await _repository.sendPasswordResetEmail(email);
  //   } catch (e) {
  //     throw Exception('فشل إرسال رابط التعيين: $e');
  //   }
  // }
}