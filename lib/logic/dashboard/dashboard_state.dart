// lib/logic/dashboard/dashboard_state.dart

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final Map<String, dynamic> stats;
  final DateTime selectedDate;
  final String selectedDelegateId;

  DashboardLoaded({
    required this.stats,
    required this.selectedDate,
    required this.selectedDelegateId,
  });
}
class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}