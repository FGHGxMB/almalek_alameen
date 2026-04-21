// lib/logic/settings/settings_state.dart

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}
class SettingsLoading extends SettingsState {}
class SettingsSuccess extends SettingsState {
  final String message;
  SettingsSuccess(this.message);
}
class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}