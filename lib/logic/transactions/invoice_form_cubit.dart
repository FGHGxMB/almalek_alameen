// lib/logic/transactions/invoice_form_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/customers_repository.dart';
import '../../data/repositories/products_repository.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/transaction_item_model.dart';

abstract class InvoiceFormState {}

class InvoiceFormInitial extends InvoiceFormState {}
class InvoiceFormLoading extends InvoiceFormState {}
class InvoiceFormReady extends InvoiceFormState {
  final List<CustomerModel> customers;
  final List<ProductModel> products;
  final List<TransactionItemModel> selectedItems;
  final double discount;
  final String paymentMethod;
  final double total;

  InvoiceFormReady({
    required this.customers,
    required this.products,
    required this.selectedItems,
    this.discount = 0.0,
    this.paymentMethod = 'cash',
    required this.total,
  });
}
class InvoiceFormSuccess extends InvoiceFormState {}
class InvoiceFormError extends InvoiceFormState {
  final String message;
  InvoiceFormError(this.message);
}

class InvoiceFormCubit extends Cubit<InvoiceFormState> {
  final CustomersRepository _customersRepo;
  final ProductsRepository _productsRepo;
  final TransactionsRepository _transactionsRepo;
  final UserModel currentUser;

  StreamSubscription? _customersSub;
  List<CustomerModel> _customers =[];
  List<ProductModel> _products = [];
  List<TransactionItemModel> _selectedItems =[];
  double _discount = 0.0;
  String _paymentMethod = 'cash';

  InvoiceFormCubit(this._customersRepo, this._productsRepo, this._transactionsRepo, this.currentUser) : super(InvoiceFormInitial()) {
    _initData();
  }

  void _initData() async {
    emit(InvoiceFormLoading());
    try {
      _products = await _productsRepo.getLocalProducts();
      _customersSub = _customersRepo.getCustomersStream(currentUser).listen((customers) {
        _customers = customers;
        _emitReady();
      });
    } catch (e) {
      emit(InvoiceFormError('خطأ في جلب البيانات: $e'));
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

  void updateDiscount(double discount) {
    _discount = discount;
    _emitReady();
  }

  void updatePaymentMethod(String method) {
    _paymentMethod = method;
    _emitReady();
  }

  Future<void> submitInvoice({required CustomerModel selectedCustomer, required String note}) async {
    if (_selectedItems.isEmpty) {
      emit(InvoiceFormError('يجب إضافة مادة واحدة على الأقل للفاتورة.'));
      _emitReady();
      return;
    }
    emit(InvoiceFormLoading());
    try {
      final invoice = InvoiceModel(
        id: '',
        invoiceNumber: 0,
        delegateInvoiceNumber: 0,
        invoiceDate: DateTime.now(),
        customerId: selectedCustomer.id,
        customerName: selectedCustomer.customerName,
        warehouseCode: currentUser.warehouseCode,
        paymentMethod: _paymentMethod,
        invoiceNote: note,
        discount: _discount,
        costCenterCode: currentUser.costCenterCode,
        isSynced: false,
        pendingAction: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        delegateId: currentUser.id,
        items: _selectedItems,
      );

      await _transactionsRepo.createInvoice(invoice, currentUser);
      emit(InvoiceFormSuccess());
    } catch (e) {
      emit(InvoiceFormError('حدث خطأ أثناء الحفظ: $e'));
      _emitReady();
    }
  }

  void _emitReady() {
    double t = 0;
    for (var i in _selectedItems) {
      t += (i.price * i.quantity);
    }
    emit(InvoiceFormReady(
      customers: _customers,
      products: _products,
      selectedItems: List.from(_selectedItems),
      discount: _discount,
      paymentMethod: _paymentMethod,
      total: t - _discount,
    ));
  }

  @override
  Future<void> close() {
    _customersSub?.cancel();
    return super.close();
  }
}