import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/firestore_keys.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;
  final UserModel currentUser;

  DateTime _selectedDate = DateTime.now();
  late String _selectedDelegateId;
  Map<String, String> _delegateNames = {};

  DashboardCubit(this._repository, this.currentUser) : super(DashboardInitial()) {
    _selectedDelegateId = currentUser.id;
  }

  Future<void> fetchDashboardData() async {
    emit(DashboardLoading());
    try {
      // جلب أسماء المندوبين مرة واحدة
      if (_delegateNames.isEmpty) {
        final delegateIds = [currentUser.id, ...currentUser.canMonitor];
        final snap = await FirebaseFirestore.instance.collection(FirestoreKeys.users).where(FieldPath.documentId, whereIn: delegateIds).get();
        for (var doc in snap.docs) {
          _delegateNames[doc.id] = doc.data()[FirestoreKeys.accountName] ?? 'مجهول';
        }
      }

      final stats = await _repository.getDailyStats(delegateIds: [_selectedDelegateId], date: _selectedDate);
      emit(DashboardLoaded(stats: stats, selectedDate: _selectedDate, selectedDelegateId: _selectedDelegateId, delegateNames: _delegateNames));
    } catch (e) {
      emit(DashboardError('حدث خطأ أثناء جلب الإحصاءات: $e'));
    }
  }

  void changeDate(DateTime newDate) { _selectedDate = newDate; fetchDashboardData(); }
  void changeDelegate(String delegateId) { _selectedDelegateId = delegateId; fetchDashboardData(); }
}