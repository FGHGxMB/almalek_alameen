// lib/logic/admin/admin_state.dart
import '../../data/models/user_model.dart';

abstract class AdminState {}
class AdminLoading extends AdminState {}
class AdminLoaded extends AdminState {
  final List<UserModel> users;
  AdminLoaded(this.users);
}
class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}