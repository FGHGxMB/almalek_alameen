abstract class SettingsState {}
class SettingsInitial extends SettingsState {}
class SettingsLoading extends SettingsState {}
class SettingsLoaded extends SettingsState {
  final double currencyRate;
  final bool isConfigSynced;
  final bool isProductsSynced;
  SettingsLoaded(this.currencyRate, this.isConfigSynced, this.isProductsSynced);
}
class SettingsSuccess extends SettingsState { final String message; SettingsSuccess(this.message); }
class SettingsError extends SettingsState { final String message; SettingsError(this.message); }