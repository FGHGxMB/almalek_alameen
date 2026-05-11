abstract class DashboardState {}
class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final Map<String, dynamic> stats;
  final DateTime selectedDate;
  final String selectedDelegateId;
  final Map<String, String> delegateNames; // الحقل الجديد للأسماء

  DashboardLoaded({
    required this.stats, required this.selectedDate,
    required this.selectedDelegateId, required this.delegateNames,
  });
}
class DashboardError extends DashboardState { final String message; DashboardError(this.message); }