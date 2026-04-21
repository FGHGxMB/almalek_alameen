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

  ReceiptFormCubit(
      this._customersRepo,
      this._transactionsRepo,
      this.currentUser
      ) : super(ReceiptFormInitial()) {
    _loadCustomers();
  }

  void _loadCustomers() {
    emit(ReceiptFormLoading());
    // جلب زبائن المندوب وزبائن المندوبين الذين يراقبهم
    _customersSub = _customersRepo.getCustomersStream(currentUser).listen(
            (customers) {
          _customers = customers;
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
  }) async {
    emit(ReceiptFormLoading());
    try {
      final receipt = ReceiptModel(
        id: '', // سيتم إنشاؤه تلقائياً في المستودع
        receiptNumber: 0,
        delegateReceiptNumber: 0,
        creditorAccount: selectedCustomer.id, // الزبون الذي دفع
        debtorAccount: currentUser.id, // الصندوق/المندوب المستلم
        amount: amount,
        lineNote: note,
        costCenterCode: currentUser.costCenterCode,
        date: DateTime.now(),
        isSynced: false,
        pendingAction: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        delegateId: currentUser.id,
      );

      // عملية الإنشاء تمر عبر الـ Batch للتأثير على الكاش ورصيد الزبون
      await _transactionsRepo.createReceipt(receipt, currentUser);

      emit(ReceiptFormSuccess());
    } catch (e) {
      emit(ReceiptFormError('حدث خطأ أثناء الحفظ: $e'));
      emit(ReceiptFormReady(_customers));
    }
  }

  @override
  Future<void> close() {
    _customersSub?.cancel();
    return super.close();
  }
}