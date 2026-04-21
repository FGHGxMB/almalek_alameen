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
}