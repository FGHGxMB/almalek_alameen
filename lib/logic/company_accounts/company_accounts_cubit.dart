// lib/logic/company_accounts/company_accounts_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'company_accounts_state.dart';
import '../../data/repositories/company_accounts_repository.dart';

class CompanyAccountsCubit extends Cubit<CompanyAccountsState> {
  final CompanyAccountsRepository _repository;
  StreamSubscription? _sub;

  CompanyAccountsCubit(this._repository) : super(CompanyAccountsLoading()) {
    _sub = _repository.getCompanyAccountsStream().listen(
          (accounts) => emit(CompanyAccountsLoaded(accounts)),
      onError: (e) => emit(CompanyAccountsError('خطأ في جلب الحسابات: $e')),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}