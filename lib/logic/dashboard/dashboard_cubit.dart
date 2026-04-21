// lib/logic/dashboard/dashboard_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/models/user_model.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;
  final UserModel currentUser;

  DateTime _selectedDate = DateTime.now();
  late String _selectedDelegateId;

  DashboardCubit(this._repository, this.currentUser) : super(DashboardInitial()) {
    _selectedDelegateId = currentUser.id; // المندوب الافتراضي هو المستخدم نفسه
  }

  // جلب البيانات
  Future<void> fetchDashboardData() async {
    emit(DashboardLoading());
    try {
      final stats = await _repository.getDailyStats(
        delegateIds: [_selectedDelegateId], // نبحث للمندوب المحدد فقط
        date: _selectedDate,
      );

      emit(DashboardLoaded(
        stats: stats,
        selectedDate: _selectedDate,
        selectedDelegateId: _selectedDelegateId,
      ));
    } catch (e) {
      emit(DashboardError('حدث خطأ أثناء جلب الإحصاءات: $e'));
    }
  }

  // تغيير التاريخ
  void changeDate(DateTime newDate) {
    _selectedDate = newDate;
    fetchDashboardData();
  }

  // تغيير المندوب (لمن يملك صلاحية المراقبة)
  void changeDelegate(String delegateId) {
    _selectedDelegateId = delegateId;
    fetchDashboardData();
  }
}