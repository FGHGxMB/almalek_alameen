// lib/logic/transactions/invoice_form_cubit.dart
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
  final List<CustomerModel> myCustomers;
  final List<ProductModel> products;
  final List<TransactionItemModel> items;
  final double discount;
  final String paymentMethod;
  final double total;
  final double currencyRate;

  InvoiceFormReady({
    required this.myCustomers, required this.products, required this.items,
    this.discount = 0.0, this.paymentMethod = 'cash', required this.total, required this.currencyRate,
  });
}
class InvoiceFormSuccess extends InvoiceFormState {}
class InvoiceFormError extends InvoiceFormState { final String message; InvoiceFormError(this.message); }

class InvoiceFormCubit extends Cubit<InvoiceFormState> {
  final CustomersRepository _customersRepo;
  final ProductsRepository _productsRepo;
  final TransactionsRepository _transactionsRepo;
  final UserModel currentUser;

  List<CustomerModel> _myCustomers =[];
  List<ProductModel> _products = [];
  List<TransactionItemModel> _items =[];
  double _discount = 0.0;
  String _paymentMethod = 'cash';
  double _currencyRate = 1.0;

  InvoiceFormCubit(this._customersRepo, this._productsRepo, this._transactionsRepo, this.currentUser) : super(InvoiceFormInitial());

  void initData({InvoiceModel? invoiceToEdit}) async {
    emit(InvoiceFormLoading());
    try {
      _currencyRate = await _transactionsRepo.getCurrencyRate();
      _products = await _productsRepo.getLocalProducts();

      _customersRepo.getCustomersStream(currentUser).listen((all) {
        _myCustomers = all.where((c) => c.delegateId == currentUser.id).toList();

        if (invoiceToEdit != null) {
          _items = List.from(invoiceToEdit.items);
          _discount = invoiceToEdit.discount;
          _paymentMethod = invoiceToEdit.paymentMethod;
        }
        _emitReady();
      });
    } catch (e) { emit(InvoiceFormError('خطأ: $e')); }
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

  void toggleGift(int index) {
    final i = _items[index];
    _items[index] = i.copyWith(isGift: !i.isGift);
    _emitReady();
  }

  void updateItem(int index, double qty, String unit, double price) {
    final i = _items[index];
    _items[index] = i.copyWith(quantity: qty, unit: unit, price: price);
    _emitReady();
  }

  void removeItem(int index) { _items.removeAt(index); _emitReady(); }
  void updateDiscount(double d) { _discount = d; _emitReady(); }
  void updatePaymentMethod(String m) { _paymentMethod = m; _emitReady(); }

  Future<void> submitInvoice({CustomerModel? selectedCustomer, required String note, InvoiceModel? oldInvoice}) async {
    if (_items.isEmpty) { emit(InvoiceFormError('الفاتورة فارغة.')); _emitReady(); return; }

    // شرط الزبون والنقدي (ألغينا السماح للهدية من هنا لأنها تلقائية)
    if (selectedCustomer == null && _paymentMethod == 'credit') {
      emit(InvoiceFormError('الفواتير الآجلة تتطلب تحديد زبون.')); _emitReady(); return;
    }

    emit(InvoiceFormLoading());
    try {
      // التحقق التلقائي: هل كل الأقلام هدايا؟
      bool allGifts = _items.isNotEmpty && _items.every((i) => i.isGift);
      String finalPaymentMethod = allGifts ? 'gift' : _paymentMethod;

      final invoice = InvoiceModel(
        id: oldInvoice?.id ?? '',
        invoiceNumber: oldInvoice?.invoiceNumber ?? 0,
        delegateInvoiceNumber: oldInvoice?.delegateInvoiceNumber ?? 0,
        invoiceDate: oldInvoice?.invoiceDate ?? DateTime.now(),
        customerId: selectedCustomer?.id ?? oldInvoice?.customerId ?? '',
        customerName: selectedCustomer?.customerName ?? oldInvoice?.customerName ?? 'زبون نقدي',
        warehouseCode: currentUser.warehouseCode,
        paymentMethod: finalPaymentMethod, // نمرر النوع النهائي
        invoiceNote: note, discount: _discount, costCenterCode: currentUser.costCenterCode,
        isSynced: false, pendingAction: '', createdAt: oldInvoice?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(), delegateId: oldInvoice?.delegateId ?? currentUser.id, items: _items,
      );

      if (oldInvoice == null) {
        _transactionsRepo.createInvoice(invoice, currentUser);
      } else {
        _transactionsRepo.updateInvoice(oldInvoice, invoice);
      }
      emit(InvoiceFormSuccess());
    } catch (e) { emit(InvoiceFormError('خطأ: $e')); _emitReady(); }
  }

  Future<void> deleteInvoice(InvoiceModel invoice) async {
    emit(InvoiceFormLoading());
    try {
      _transactionsRepo.deleteInvoice(invoice);
      emit(InvoiceFormSuccess());
    } catch (e) { emit(InvoiceFormError('خطأ أثناء الحذف: $e')); _emitReady(); }
  }

  void _emitReady() {
    double t = 0;
    bool allGifts = _items.isNotEmpty && _items.every((i) => i.isGift);
    if (allGifts) _discount = 0;
    for (var i in _items) { if (!i.isGift) t += (i.price * i.quantity); }
    emit(InvoiceFormReady(myCustomers: _myCustomers, products: _products, items: List.from(_items), discount: _discount, paymentMethod: _paymentMethod, total: t - _discount, currencyRate: _currencyRate));
  }
}