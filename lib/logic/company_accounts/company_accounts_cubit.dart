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

  // إعادة الترتيب المخصصة لكل تبويب لكي لا تختلط الأرقام
  Future<void> reorder(int oldIndex, int newIndex, List<CompanyAccountModel> tabList) async {
    if (state is CompanyAccountsLoaded) {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = tabList.removeAt(oldIndex);
      tabList.insert(newIndex, item);

      // نعكس الترتيب محلياً قبل السيرفر (نحدث القائمة الرئيسية بالترتيب الجديد)
      final allAccounts = List<CompanyAccountModel>.from((state as CompanyAccountsLoaded).accounts);
      for (int i = 0; i < tabList.length; i++) {
        final currentAccount = tabList[i];
        final globalIndex = allAccounts.indexWhere((a) => a.id == currentAccount.id);
        if (globalIndex != -1) {
          allAccounts[globalIndex] = currentAccount.copyWith(orderIndex: i);
        }
      }

      emit(CompanyAccountsLoaded(allAccounts));

      try {
        await _repository.reorderAccounts(tabList);
      } catch (e) {
        // خطأ صامت في السحب
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