// lib/logic/transactions/return_form_cubit.dart
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
  final List<CustomerModel> myCustomers;
  final List<ProductModel> products;
  final List<TransactionItemModel> items;
  final String paymentMethod;
  final double total;
  final double currencyRate;

  ReturnFormReady({
    required this.myCustomers, required this.products, required this.items,
    this.paymentMethod = 'cash', required this.total, required this.currencyRate,
  });
}
class ReturnFormSuccess extends ReturnFormState {}
class ReturnFormError extends ReturnFormState { final String message; ReturnFormError(this.message); }

class ReturnFormCubit extends Cubit<ReturnFormState> {
  final CustomersRepository _customersRepo;
  final ProductsRepository _productsRepo;
  final TransactionsRepository _transactionsRepo;
  final UserModel currentUser;

  List<CustomerModel> _myCustomers =[];
  List<ProductModel> _products =[];
  List<TransactionItemModel> _items =[];
  String _paymentMethod = 'cash';
  double _currencyRate = 1.0;

  ReturnFormCubit(this._customersRepo, this._productsRepo, this._transactionsRepo, this.currentUser) : super(ReturnFormInitial());

  void initData({ReturnModel? returnToEdit}) async {
    emit(ReturnFormLoading());
    try {
      _currencyRate = await _transactionsRepo.getCurrencyRate();
      _products = await _productsRepo.getLocalProducts();

      _customersRepo.getCustomersStream(currentUser).listen((all) {
        _myCustomers = all.where((c) => c.delegateId == currentUser.id).toList();

        if (returnToEdit != null) {
          _items = List.from(returnToEdit.items);
          _paymentMethod = returnToEdit.paymentMethod;
        }
        _emitReady();
      });
    } catch (e) { emit(ReturnFormError('خطأ: $e')); }
  }

  void addItem(ProductModel p, double qty, String unit, double price, bool isGift) {
    _items.add(TransactionItemModel(productId: p.id, quantity: qty, unit: unit, price: price, isGift: isGift));
    _emitReady();
  }

  void reorderItems(int oldIdx, int newIdx) {
    if (newIdx > oldIdx) newIdx -= 1;
    final item = _items.removeAt(oldIdx);
    _items.insert(newIdx, item);
    _emitReady();
  }

  void updateItem(int index, double qty, String unit, double price) {
    final i = _items[index];
    _items[index] = i.copyWith(quantity: qty, unit: unit, price: price);
    _emitReady();
  }

  void removeItem(int index) { _items.removeAt(index); _emitReady(); }
  void updatePaymentMethod(String m) { _paymentMethod = m; _emitReady(); }

  Future<void> submitReturn({CustomerModel? selectedCustomer, required String note, ReturnModel? oldReturn}) async {
    if (_items.isEmpty) { emit(ReturnFormError('المرتجع فارغ.')); _emitReady(); return; }

    // التعديل هنا: نطلب الزبون فقط في المرتجع الآجل
    if (selectedCustomer == null && _paymentMethod == 'credit') {
      emit(ReturnFormError('المرتجعات الآجلة تتطلب تحديد زبون.')); _emitReady(); return;
    }

    emit(ReturnFormLoading());
    try {
      final returnDoc = ReturnModel(
        id: oldReturn?.id ?? '',
        returnNumber: oldReturn?.returnNumber ?? 0,
        delegateReturnNumber: oldReturn?.delegateReturnNumber ?? 0,
        returnDate: oldReturn?.returnDate ?? DateTime.now(),
        // التعديل هنا لتسجيل "زبون نقدي"
        customerId: selectedCustomer?.id ?? oldReturn?.customerId ?? '',
        customerName: selectedCustomer?.customerName ?? oldReturn?.customerName ?? 'زبون نقدي',
        warehouseCode: currentUser.warehouseCode,
        paymentMethod: _paymentMethod,
        returnNote: note,
        invoiceRef: '',
        costCenterCode: currentUser.costCenterCode, isSynced: false,
        pendingAction: '', createdAt: oldReturn?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(), delegateId: oldReturn?.delegateId ?? currentUser.id, items: _items,
      );

      if (oldReturn == null) {
        _transactionsRepo.createReturn(returnDoc, currentUser);
      } else {
        _transactionsRepo.updateReturn(oldReturn, returnDoc);
      }
      emit(ReturnFormSuccess());
    } catch (e) { emit(ReturnFormError('خطأ: $e')); _emitReady(); }
  }

  Future<void> deleteReturn(ReturnModel returnDoc) async {
    emit(ReturnFormLoading());
    try {
      _transactionsRepo.deleteReturn(returnDoc);
      emit(ReturnFormSuccess());
    } catch (e) { emit(ReturnFormError('خطأ أثناء الحذف: $e')); _emitReady(); }
  }

  void _emitReady() {
    double t = 0;
    for (var i in _items) { t += (i.price * i.quantity); }
    emit(ReturnFormReady(myCustomers: _myCustomers, products: _products, items: List.from(_items), paymentMethod: _paymentMethod, total: t, currencyRate: _currencyRate));
  }
}