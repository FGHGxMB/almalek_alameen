// lib/logic/transactions/receipt_form_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/customers_repository.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/receipt_model.dart';

abstract class ReceiptFormState {}

class ReceiptFormInitial extends ReceiptFormState {}
class ReceiptFormLoading extends ReceiptFormState {}
class ReceiptFormReady extends ReceiptFormState {
  final List<CustomerModel> customers;
  ReceiptFormReady(this.customers);
}
class ReceiptFormSuccess extends ReceiptFormState {}
class ReceiptFormError extends ReceiptFormState {
  final String message;
  ReceiptFormError(this.message);
}

class ReceiptFormCubit extends Cubit<ReceiptFormState> {
  final CustomersRepository _customersRepo;
  final TransactionsRepository _transactionsRepo;
  final UserModel currentUser;

  StreamSubscription? _customersSub;
  List<CustomerModel> _customers =[];

  ReceiptFormCubit(this._customersRepo, this._transactionsRepo, this.currentUser) : super(ReceiptFormInitial());

  void initData({ReceiptModel? receiptToEdit}) {
    emit(ReceiptFormLoading());
    _customersSub = _customersRepo.getCustomersStream(currentUser).listen(
            (customers) {
          _customers = customers.where((c) => c.delegateId == currentUser.id).toList(); // زبائني فقط
          emit(ReceiptFormReady(_customers));
        },
        onError: (e) {
          emit(ReceiptFormError('خطأ في جلب الزبائن: $e'));
        }
    );
  }

  Future<void> submitReceipt({
    required CustomerModel selectedCustomer,
    required double amount,
    required String note,
    ReceiptModel? oldReceipt,
  }) async {
    emit(ReceiptFormLoading());
    try {
      final receipt = ReceiptModel(
        id: oldReceipt?.id ?? '',
        receiptNumber: oldReceipt?.receiptNumber ?? 0,
        delegateReceiptNumber: oldReceipt?.delegateReceiptNumber ?? 0,
        creditorAccount: selectedCustomer.id,
        debtorAccount: currentUser.id,
        amount: amount,
        lineNote: note,
        costCenterCode: currentUser.costCenterCode,
        date: oldReceipt?.date ?? DateTime.now(),
        isSynced: false,
        pendingAction: '',
        createdAt: oldReceipt?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        delegateId: oldReceipt?.delegateId ?? currentUser.id,
      );

      if (oldReceipt == null) {
        _transactionsRepo.createReceipt(receipt, currentUser); // بدون await لتغلق بسرعة
      } else {
        _transactionsRepo.updateReceipt(oldReceipt, receipt);
      }

      emit(ReceiptFormSuccess());
    } catch (e) {
      emit(ReceiptFormError('حدث خطأ أثناء الحفظ: $e'));
      emit(ReceiptFormReady(_customers));
    }
  }

  Future<void> deleteReceipt(ReceiptModel receipt) async {
    emit(ReceiptFormLoading());
    try {
      _transactionsRepo.deleteReceipt(receipt);
      emit(ReceiptFormSuccess());
    } catch (e) {
      emit(ReceiptFormError('خطأ أثناء الحذف: $e'));
      emit(ReceiptFormReady(_customers));
    }
  }

  @override
  Future<void> close() {
    _customersSub?.cancel();
    return super.close();
  }
}