// lib/logic/company_accounts/company_accounts_state.dart

import '../../data/models/company_account_model.dart';

abstract class CompanyAccountsState {}

class CompanyAccountsLoading extends CompanyAccountsState {}

class CompanyAccountsLoaded extends CompanyAccountsState {
  final List<CompanyAccountModel> accounts;
  CompanyAccountsLoaded(this.accounts);
}

class CompanyAccountsError extends CompanyAccountsState {
  final String message;
  CompanyAccountsError(this.message);
}