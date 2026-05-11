abstract class SettingsState {}
class SettingsInitial extends SettingsState {}
class SettingsLoading extends SettingsState {}
class SettingsLoaded extends SettingsState {
  final double currencyRate;
  final bool isSynced;
  SettingsLoaded(this.currencyRate, this.isSynced);
}
class SettingsSuccess extends SettingsState { final String message; SettingsSuccess(this.message); }
class SettingsError extends SettingsState { final String message; SettingsError(this.message); }