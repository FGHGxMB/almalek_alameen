// lib/logic/company_accounts/company_accounts_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'company_accounts_state.dart';
import '../../data/repositories/company_accounts_repository.dart';
import '../../data/models/company_account_model.dart';

class CompanyAccountsCubit extends Cubit<CompanyAccountsState> {
  final CompanyAccountsRepository _repository;
  StreamSubscription? _sub;

  CompanyAccountsCubit(this._repository) : super(CompanyAccountsLoading()) {
    _sub = _repository.getCompanyAccountsStream().listen(
          (accounts) => emit(CompanyAccountsLoaded(accounts)),
      onError: (e) => emit(CompanyAccountsError('خطأ في جلب الحسابات: $e')),
    );
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (state is CompanyAccountsLoaded) {
      final currentState = state as CompanyAccountsLoaded;
      final list = List<CompanyAccountModel>.from(currentState.accounts);

      if (newIndex > oldIndex) newIndex -= 1;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);

      // نعكس التغيير محلياً فوراً للشعور بالسرعة، ثم نرسله للسيرفر
      emit(CompanyAccountsLoaded(list));
      try {
        await _repository.reorderAccounts(list);
      } catch (e) {
        // في حال الفشل، يمكنك إعادة تحميل البيانات
      }
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      await _repository.deleteCompanyAccount(id);
    } catch (e) {
      emit(CompanyAccountsError('فشل החذف: $e'));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}