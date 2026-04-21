// lib/logic/transactions/return_form_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/customers_repository.dart';
import '../../data/repositories/products_repository.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/return_model.dart';
import '../../data/models/transaction_item_model.dart';

abstract class ReturnFormState {}

class ReturnFormInitial extends ReturnFormState {}
class ReturnFormLoading extends ReturnFormState {}
class ReturnFormReady extends ReturnFormState {
  final List<CustomerModel> customers;
  final List<ProductModel> products;
  final List<TransactionItemModel> selectedItems;
  final String paymentMethod;
  final double total;

  ReturnFormReady({
    required this.customers,
    required this.products,
    required this.selectedItems,
    this.paymentMethod = 'cash',
    required this.total,
  });
}
class ReturnFormSuccess extends ReturnFormState {}
class ReturnFormError extends ReturnFormState {
  final String message;
  ReturnFormError(this.message);
}

class ReturnFormCubit extends Cubit<ReturnFormState> {
  final CustomersRepository _customersRepo;
  final ProductsRepository _productsRepo;
  final TransactionsRepository _transactionsRepo;
  final UserModel currentUser;

  StreamSubscription? _customersSub;
  List<CustomerModel> _customers =[];
  List<ProductModel> _products = [];
  List<TransactionItemModel> _selectedItems =[];
  String _paymentMethod = 'cash';

  ReturnFormCubit(this._customersRepo, this._productsRepo, this._transactionsRepo, this.currentUser) : super(ReturnFormInitial()) {
    _initData();
  }

  void _initData() async {
    emit(ReturnFormLoading());
    try {
      _products = await _productsRepo.getLocalProducts();
      _customersSub = _customersRepo.getCustomersStream(currentUser).listen((customers) {
        _customers = customers;
        _emitReady();
      });
    } catch (e) {
      emit(ReturnFormError('خطأ في جلب البيانات: $e'));
    }
  }

  void addItem(ProductModel product, double quantity, String unit, double price) {
    final idx = _selectedItems.indexWhere((i) => i.productId == product.id && i.unit == unit);
    if (idx >= 0) {
      final current = _selectedItems[idx];
      _selectedItems[idx] = current.copyWith(quantity: current.quantity + quantity);
    } else {
      _selectedItems.add(TransactionItemModel(productId: product.id, quantity: quantity, unit: unit, price: price));
    }
    _emitReady();
  }

  void removeItem(String productId, String unit) {
    _selectedItems.removeWhere((i) => i.productId == productId && i.unit == unit);
    _emitReady();
  }

  void updatePaymentMethod(String method) {
    _paymentMethod = method;
    _emitReady();
  }

  Future<void> submitReturn({
    required CustomerModel selectedCustomer,
    required String note,
    required String invoiceRef
  }) async {
    if (_selectedItems.isEmpty) {
      emit(ReturnFormError('يجب إضافة مادة واحدة على الأقل للمرتجع.'));
      _emitReady();
      return;
    }
    emit(ReturnFormLoading());
    try {
      final returnDoc = ReturnModel(
        id: '',
        returnNumber: 0,
        delegateReturnNumber: 0,
        returnDate: DateTime.now(),
        customerId: selectedCustomer.id,
        customerName: selectedCustomer.customerName,
        warehouseCode: currentUser.warehouseCode,
        paymentMethod: _paymentMethod,
        returnNote: note,
        invoiceRef: invoiceRef, // رقم الفاتورة الأصلية (اختياري)
        costCenterCode: currentUser.costCenterCode,
        isSynced: false,
        pendingAction: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        delegateId: currentUser.id,
        items: _selectedItems,
      );

      await _transactionsRepo.createReturn(returnDoc, currentUser);
      emit(ReturnFormSuccess());
    } catch (e) {
      emit(ReturnFormError('حدث خطأ أثناء الحفظ: $e'));
      _emitReady();
    }
  }

  void _emitReady() {
    double t = 0;
    for (var i in _selectedItems) {
      t += (i.price * i.quantity);
    }
    emit(ReturnFormReady(
      customers: _customers,
      products: _products,
      selectedItems: List.from(_selectedItems),
      paymentMethod: _paymentMethod,
      total: t, // لا يوجد حسم في المرتجع
    ));
  }

  @override
  Future<void> close() {
    _customersSub?.cancel();
    return super.close();
  }
}