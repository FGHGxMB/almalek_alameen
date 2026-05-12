// lib/ui/screens/transactions/invoice_form_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spice_app/data/models/user_model.dart';
import '../../../core/constants/firestore_keys.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/transactions/invoice_form_cubit.dart';
import '../../../data/repositories/customers_repository.dart';
import '../../../data/repositories/products_repository.dart';
import '../../../data/repositories/transactions_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/product_selection_grid.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/models/unified_transaction.dart';

class InvoiceFormScreen extends StatefulWidget {
  final InvoiceModel? invoiceToEdit;
  const InvoiceFormScreen({Key? key, this.invoiceToEdit}) : super(key: key);
  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _noteController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  CustomerModel? _selectedCustomer;
  bool isViewMode = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  String _formatNum(double num) => NumberFormat('#,##0').format(num);
  String _rawNum(double num) => num == num.toInt() ? num.toInt().toString() : num.toString();

  String _cleanCustomerName(String fullName, String suffix) {
    if (suffix.isNotEmpty && fullName.startsWith(suffix)) {
      return fullName.replaceFirst(suffix, '').trim();
    }
    return fullName;
  }

  @override
  void initState() {
    super.initState();
    isViewMode = widget.invoiceToEdit != null;
    if (isViewMode) {
      _noteController.text = widget.invoiceToEdit!.invoiceNote;
      _discountController.text = widget.invoiceToEdit!.discount.toString();
    }
  }

  // --- دالة حوار الحذف بثلاث ثوانٍ ---
  void _showDeleteDialog(BuildContext context, InvoiceFormCubit cubit) {
    showDialog(context: context, builder: (ctx) {
      return StreamBuilder<int>(
          stream: Stream.periodic(const Duration(seconds: 1), (i) => 3 - i - 1).take(3),
          builder: (context, snapshot) {
            final timeLeft = snapshot.data ?? 3;
            final isReady = timeLeft <= 0;
            return AlertDialog(
              title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.red)),
              content: const Text('هل أنت متأكد من حذف هذه الفاتورة نهائياً؟ سيتم عكس الأرصدة.'),
              actions:[
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: isReady ? () { cubit.deleteInvoice(widget.invoiceToEdit!); Navigator.pop(ctx); } : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(isReady ? 'حذف الفاتورة' : 'حذف ($timeLeft)'),
                ),
              ],
            );
          }
      );
    });
  }

  // --- دالة حوار الطباعة والمشاركة ---
  void _showPrintShareDialog(BuildContext context, InvoiceFormReady state, bool isShare, UserModel currentUser) {
    // 1. محاولة إيجاد الزبون لتوليد بياناته
    CustomerModel? c;
    try { c = state.myCustomers.firstWhere((cust) => cust.id == widget.invoiceToEdit!.customerId); } catch(e){}

    // 2. توليد العنوان الافتراضي (منطقة - حي - شارع)
    String defaultAddress = widget.invoiceToEdit!.printAddress;
    if (defaultAddress.isEmpty && c != null) {
      List<String> addressParts =[];
      if (c.region.isNotEmpty) addressParts.add(c.region);
      if (c.district.isNotEmpty) addressParts.add(c.district);
      if (c.street.isNotEmpty) addressParts.add(c.street);
      defaultAddress = addressParts.join(' - ');
    }

    // 3. توليد الهاتف الافتراضي
    String defaultPhone = widget.invoiceToEdit!.printPhone;
    if (defaultPhone.isEmpty && c != null) {
      defaultPhone = c.phone1.isNotEmpty ? c.phone1 : c.phone2;
    }

    final nameCtrl = TextEditingController(text: widget.invoiceToEdit?.customerName ?? '');
    final addressCtrl = TextEditingController(text: defaultAddress);
    final phoneCtrl = TextEditingController(text: defaultPhone);
    final delegateCtrl = TextEditingController(text: currentUser.accountName);

    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text(isShare ? 'تجهيز الصورة للمشاركة' : 'إعداد الطباعة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الزبون', border: OutlineInputBorder(), isDense: true)), const SizedBox(height: 8),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'العنوان (للطباعة)', border: OutlineInputBorder(), isDense: true)), const SizedBox(height: 8),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder(), isDense: true)), const SizedBox(height: 8),
              TextField(controller: delegateCtrl, decoration: const InputDecoration(labelText: 'المندوب', border: OutlineInputBorder(), isDense: true)),
            ],
          ),
        ),
        actions:[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              Navigator.pop(ctx);

              // حفظ بيانات الطباعة في السيرفر للمرات القادمة
              context.read<TransactionsRepository>().savePrintData(
                  FirestoreKeys.invoices, widget.invoiceToEdit!.id, addressCtrl.text.trim(), phoneCtrl.text.trim()
              );

              if (isShare) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تجهيز الصورة...')));
                final widgetToCapture = Theme(
                  data: ThemeData.light(),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
                      color: Colors.white,
                      child: _buildReceiptWidgetForImage(state, nameCtrl.text, addressCtrl.text, phoneCtrl.text, delegateCtrl.text),
                    ),
                  ),
                );
                try {
                  final bytes = await _screenshotController.captureFromWidget(widgetToCapture, delay: const Duration(milliseconds: 500));
                  final directory = await getApplicationDocumentsDirectory();
                  final imagePath = '${directory.path}/invoice_${widget.invoiceToEdit?.delegateInvoiceNumber ?? 'new'}.png';
                  File(imagePath).writeAsBytesSync(bytes);
                  await Share.shareXFiles([XFile(imagePath)], text: 'مرفق صورة الفاتورة');
                } catch(e) {}
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري الاتصال بالطابعة...')));
                final t = UnifiedTransaction(
                    id: widget.invoiceToEdit!.id, type: TransactionType.invoice, date: widget.invoiceToEdit!.invoiceDate, updatedAt: widget.invoiceToEdit!.updatedAt,
                    localNumber: widget.invoiceToEdit!.delegateInvoiceNumber, globalNumber: widget.invoiceToEdit!.invoiceNumber,
                    customerId: widget.invoiceToEdit!.customerId, // <--- السطر المضاف
                    customerName: nameCtrl.text, amount: state.total + state.discount, isSynced: true, delegateId: currentUser.id,
                    delegateName: delegateCtrl.text, delegateColor: '#000000', delegateSuffix: '', paymentMethod: state.paymentMethod, showModifiedDate: false, originalDoc: widget.invoiceToEdit!
                );
                PrinterService().printTransaction(t);
              }
            },
            child: Text(isShare ? 'مشاركة' : 'طباعة', style: const TextStyle(color: Colors.white)),
          )
        ],
      );
    });
  }

  // --- تصميم الفاتورة للصورة (للمشاركة) ---
  Widget _buildReceiptWidgetForImage(InvoiceFormReady state, String cName, String cAddress, String cPhone, String dName) {
    return Container(
      width: 400, padding: const EdgeInsets.all(16), color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          const Text('المالك الأمين للبهارات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('فاتورة مبيعات رقم: ${widget.invoiceToEdit?.delegateInvoiceNumber.toString().padLeft(5, '0') ?? ''}'),
          const Divider(thickness: 2),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[Text('الزبون: $cName'), Text('التاريخ: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}')]),
          if(cAddress.isNotEmpty) Row(children:[Text('العنوان: $cAddress')]),
          if(cPhone.isNotEmpty) Row(children:[Text('الهاتف: $cPhone')]),
          if(dName.isNotEmpty) Row(children:[Text('المندوب: $dName')]),
          const Divider(thickness: 2),
          Table(
              columnWidths: const { 0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1) },
              children:[
                const TableRow(children:[Text('المادة', style: TextStyle(fontWeight: FontWeight.bold)), Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold)), Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))]),
                ...state.items.map((i) {
                  final pName = state.products.firstWhere((p) => p.id == i.productId).itemName;
                  return TableRow(children:[Text(i.isGift?'$pName (هدية)':pName), Text('${_formatNum(i.quantity)} ${i.unit}'), Text(i.isGift?'0':_formatNum(i.quantity*i.price))]);
                }).toList(),
              ]
          ),
          const Divider(thickness: 2),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text('الصافي النهائي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(_formatNum(state.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, InvoiceFormCubit cubit, int index, var item, List<ProductModel> products, double currencyRate) {
    if (item.isGift) return; // الهدية لا تعدل أسعارها

    final product = products.firstWhere((p) => p.id == item.productId);
    double qty = item.quantity;
    String u = item.unit;
    double price = item.price;
    double minPrice = item.minPrice;

    final qtyCtrl = TextEditingController(text: _rawNum(qty));
    final priceCtrl = TextEditingController(text: _rawNum(price));

    String? qtyError;
    String? priceError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          bool isPriceLocked = (price == minPrice && minPrice > 0);

          return AlertDialog(
            title: Text('تعديل ${product.itemName}', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  TextFormField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'الكمية',
                      border: const OutlineInputBorder(),
                      errorText: qtyError,
                      suffixIcon: IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { qtyCtrl.clear(); setState(() => qty = 0); }),
                    ),
                    onChanged: (v) {
                      setState(() {
                        qty = double.tryParse(v) ?? 0;
                        qtyError = qty <= 0 ? 'لا يمكن أن تكون صفراً أو سالبة' : null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: u,
                    decoration: const InputDecoration(labelText: 'الوحدة', border: OutlineInputBorder()),
                    items:[
                      if (product.unit1.isNotEmpty) DropdownMenuItem(value: product.unit1, child: Text(product.unit1)),
                      if (product.unit2.isNotEmpty) DropdownMenuItem(value: product.unit2, child: Text(product.unit2)),
                      if (product.unit3.isNotEmpty) DropdownMenuItem(value: product.unit3, child: Text(product.unit3)),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          u = v;
                          if (v == product.unit1) { price = product.shopPrice1 * currencyRate; minPrice = product.minPrice1 * currencyRate; }
                          if (v == product.unit2) { price = product.shopPrice2 * currencyRate; minPrice = product.minPrice2 * currencyRate; }
                          if (v == product.unit3) { price = product.shopPrice3 * currencyRate; minPrice = product.minPrice3 * currencyRate; }
                          priceCtrl.text = _rawNum(price);
                          isPriceLocked = (price == minPrice && minPrice > 0);
                          priceError = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    readOnly: isPriceLocked,
                    decoration: InputDecoration(
                      labelText: isPriceLocked ? 'السعر (مقفل على الحد الأدنى)' : 'السعر الإفرادي',
                      filled: isPriceLocked,
                      fillColor: isPriceLocked ? Colors.grey.shade200 : Colors.white,
                      border: const OutlineInputBorder(),
                      errorText: priceError,
                      suffixIcon: isPriceLocked ? null : IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { priceCtrl.clear(); setState(() => price = 0); }),
                    ),
                    onChanged: (v) {
                      setState(() {
                        price = double.tryParse(v) ?? 0;
                        if (price <= 0) {
                          priceError = 'لا يمكن أن يكون صفراً أو سالباً';
                        } else if (minPrice > 0 && price < minPrice) {
                          priceError = 'لا يمكن النزول تحت الأدنى: ${_formatNum(minPrice)}';
                        } else {
                          priceError = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 6),
                  if (minPrice > 0)
                    Text('السعر الأدنى: ${_formatNum(minPrice)}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            actions:[
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    qtyError = qty <= 0 ? 'لا يمكن أن تكون صفراً أو سالبة' : null;
                    if (price <= 0) {
                      priceError = 'لا يمكن أن يكون صفراً أو سالباً';
                    } else if (minPrice > 0 && price < minPrice) {
                      priceError = 'لا يمكن النزول تحت السعر الأدنى';
                    } else {
                      priceError = null;
                    }
                  });

                  if (qtyError == null && priceError == null) {
                    cubit.updateItem(index, qty, u, price);
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                child: const Text('حفظ التعديل', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final currentUser = authState.user;

    final isMine = widget.invoiceToEdit == null || widget.invoiceToEdit!.delegateId == currentUser.id;
    final canEdit = (isMine && currentUser.permissions.invoiceEdit) || (!isMine && currentUser.permissions.invoiceEditMonitored);
    final canDelete = (isMine && currentUser.permissions.invoiceDelete) || (!isMine && currentUser.permissions.invoiceDeleteMonitored);

    return BlocProvider(
      create: (context) => InvoiceFormCubit(context.read<CustomersRepository>(), context.read<ProductsRepository>(), context.read<TransactionsRepository>(), currentUser)..initData(invoiceToEdit: widget.invoiceToEdit),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isViewMode ? 'عرض الفاتورة #${widget.invoiceToEdit!.delegateInvoiceNumber.toString().padLeft(5, '0')}' : (widget.invoiceToEdit != null ? 'تعديل الفاتورة' : 'إنشاء فاتورة')),
          centerTitle: true,
          backgroundColor: isViewMode ? Colors.grey.shade700 : Colors.blue.shade700,
          foregroundColor: Colors.white,
          actions: isViewMode ?[
            BlocBuilder<InvoiceFormCubit, InvoiceFormState>(
                builder: (context, state) {
                  if (state is InvoiceFormReady) {
                    return PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') setState(() => isViewMode = false);
                        if (val == 'delete') _showDeleteDialog(context, context.read<InvoiceFormCubit>());
                        if (val == 'print') _showPrintShareDialog(context, state, false, currentUser);
                        if (val == 'share') _showPrintShareDialog(context, state, true, currentUser);
                      },
                      itemBuilder: (ctx) =>[
                        const PopupMenuItem(value: 'print', child: Row(children:[Icon(Icons.print), SizedBox(width: 8), Text('طباعة حرارية')])),
                        const PopupMenuItem(value: 'share', child: Row(children:[Icon(Icons.share), SizedBox(width: 8), Text('مشاركة صورة الفاتورة')])),
                        if (canEdit) const PopupMenuDivider(),
                        if (canEdit) const PopupMenuItem(value: 'edit', child: Row(children:[Icon(Icons.edit), SizedBox(width: 8), Text('تعديل الفاتورة')])),
                        if (canDelete) const PopupMenuItem(value: 'delete', child: Row(children:[Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('حذف الفاتورة', style: TextStyle(color: Colors.red))])),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }
            )
          ] : null,
        ),
        body: BlocConsumer<InvoiceFormCubit, InvoiceFormState>(
          listener: (context, state) {
            if (state is InvoiceFormSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت العملية بنجاح'), backgroundColor: Colors.green));
              context.pop(); // يغلق الشاشة فوراً
            } else if (state is InvoiceFormError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state is InvoiceFormLoading || state is InvoiceFormInitial) return const Center(child: CircularProgressIndicator());
            // أضفنا هذا القسم لمنع الشاشة البيضاء وعرض الخطأ بوضوح
            if (state is InvoiceFormError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      const Icon(Icons.error_outline, color: Colors.red, size: 80),
                      const SizedBox(height: 16),
                      Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      const Text('يرجى التأكد من مسح بيانات التطبيق (Clear Data) من إعدادات الهاتف لتحديث قاعدة البيانات المحلية.', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }

            if (state is InvoiceFormReady) {
              final cubit = context.read<InvoiceFormCubit>();
              bool allGifts = state.items.isNotEmpty && state.items.every((i) => i.isGift);

              if (isViewMode && _selectedCustomer == null && widget.invoiceToEdit!.customerId.isNotEmpty) {
                try { _selectedCustomer = state.myCustomers.firstWhere((c) => c.id == widget.invoiceToEdit!.customerId); } catch(e){}
              }

              return Column(
                children:[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children:[
                          Row(
                            children:[
                              Expanded(
                                flex: 2,
                                child: Autocomplete<CustomerModel>(
                                  initialValue: TextEditingValue(text: _selectedCustomer != null ? _cleanCustomerName(_selectedCustomer!.customerName, currentUser.customerSuffix) : (isViewMode ? _cleanCustomerName(widget.invoiceToEdit!.customerName, currentUser.customerSuffix) : '')),
                                  displayStringForOption: (c) => _cleanCustomerName(c.customerName, currentUser.customerSuffix),
                                  optionsBuilder: (textEditingValue) {
                                    if (isViewMode) return const Iterable<CustomerModel>.empty();
                                    if (textEditingValue.text.isEmpty) return state.myCustomers;
                                    return state.myCustomers.where((c) => _cleanCustomerName(c.customerName, currentUser.customerSuffix).toLowerCase().contains(textEditingValue.text.toLowerCase()));
                                  },
                                  onSelected: (c) => _selectedCustomer = c,
                                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                    return TextFormField(
                                      controller: controller, focusNode: focusNode, readOnly: isViewMode,
                                      decoration: InputDecoration(labelText: 'الزبون (اتركه فارغاً للنقدي)', border: const OutlineInputBorder(), isDense: true, filled: isViewMode),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: allGifts
                                    ? TextFormField(initialValue: 'فاتورة هدايا', readOnly: true, decoration: const InputDecoration(labelText: 'النوع', border: OutlineInputBorder(), isDense: true, filled: true))
                                    : DropdownButtonFormField<String>(
                                  decoration: InputDecoration(labelText: 'النوع', border: const OutlineInputBorder(), isDense: true, filled: isViewMode),
                                  value: state.paymentMethod == 'gift' ? 'cash' : state.paymentMethod, // حماية من أي خطأ
                                  items: const[
                                    DropdownMenuItem(value: 'cash', child: Text('نقدية')),
                                    DropdownMenuItem(value: 'credit', child: Text('آجلة (ذمم)'))
                                  ],
                                  onChanged: isViewMode ? null : (val) => cubit.updatePaymentMethod(val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(controller: _noteController, readOnly: isViewMode, decoration: InputDecoration(labelText: 'البيان', border: const OutlineInputBorder(), isDense: true, filled: isViewMode)),

                          const Divider(height: 32, thickness: 2),

                          // 2. ترويسة الأقلام العلوية (زر الإضافة وعدد المواد)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[
                              Text('الأقلام (${state.items.length}) | إجمالي الكمية: ${_formatNum(state.items.fold(0.0, (s, i) => s + i.quantity))}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                              if (!isViewMode)
                                ElevatedButton.icon(
                                  onPressed: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
                                    builder: (_) => FractionallySizedBox(
                                      heightFactor: 0.9,
                                      child: ProductSelectionGrid(
                                        products: state.products,
                                        currencyRate: state.currencyRate,
                                        isReturn: false,
                                        onProductAdded: (p, q, u, pr, g) => cubit.addItem(p, q, u, pr, g),
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                                  label: const Text('إضافة', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, padding: const EdgeInsets.symmetric(horizontal: 12)),
                                )
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 3. جدول الأقلام الاحترافي
                          Expanded(
                            child: Column(
                              children:[
                                // ترويسة الجدول (أسماء العواميد)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                                  child: Row(
                                    children:[
                                      Expanded(flex: 1, child: Text(isViewMode ? '#' : '#', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                                      const Expanded(flex: 4, child: Text('المادة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                                      const Expanded(flex: 2, child: Text('الكمية', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                                      const Expanded(flex: 2, child: Text('الوحدة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                                      const Expanded(flex: 3, child: Text('الإفرادي', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                                      const Expanded(flex: 3, child: Text('الإجمالي', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                                    ],
                                  ),
                                ),
                                // محتوى الجدول
                                Expanded(
                                  child: state.items.isEmpty
                                      ? Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8))),
                                      child: const Center(child: Text('الفاتورة فارغة', style: TextStyle(color: Colors.grey))))
                                      : Container(
                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8))),
                                    child: isViewMode
                                        ? ListView.builder(
                                      itemCount: state.items.length,
                                      itemBuilder: (context, index) => _buildItemRow(context, cubit, state, index, true),
                                    )
                                        : ReorderableListView.builder(
                                      buildDefaultDragHandles: false, // نلغي السحب الافتراضي لنضع الأيقونة المخصصة
                                      itemCount: state.items.length,
                                      onReorder: (oldIdx, newIdx) => cubit.reorderItems(oldIdx, newIdx),
                                      itemBuilder: (context, index) => _buildItemRow(context, cubit, state, index, false),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(16), color: Colors.blue.shade50,
                    child: SafeArea(
                      child: Row(
                        children:[
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                              Row(children:[const Text('الحسم: '), SizedBox(width: 80, child: TextFormField(controller: _discountController, readOnly: isViewMode || allGifts, keyboardType: TextInputType.number, decoration: const InputDecoration(isDense: true), onChanged: (val) => cubit.updateDiscount(double.tryParse(val) ?? 0.0)))]),
                              Text('الصافي: ${_formatNum(state.total)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                            ]),
                          ),
                          if (!isViewMode)
                            ElevatedButton(
                              onPressed: () {
                                // تعطيل الزر مؤقتاً لتجنب الدبل كليك يتم عن طريق إظهار Loading في הـ Cubit
                                cubit.submitInvoice(selectedCustomer: _selectedCustomer, note: _noteController.text.trim(), oldInvoice: widget.invoiceToEdit);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                              child: const Text('حفظ واعتماد', style: TextStyle(color: Colors.white, fontSize: 16)),
                            )
                        ],
                      ),
                    ),
                  )
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // دالة بناء القلم كصف في جدول احترافي
  Widget _buildItemRow(BuildContext context, InvoiceFormCubit cubit, InvoiceFormReady state, int index, bool isViewOnly) {
    final item = state.items[index];
    final pName = state.products.firstWhere((p) => p.id == item.productId).itemName;
    final total = item.quantity * item.price;

    // تلوين متناوب للسطور لإراحة العين (وتمييز الهدايا)
    Color bgColor = index % 2 == 0 ? Colors.white : Colors.grey.shade50;
    if (item.isGift) bgColor = Colors.indigo.shade50;

    return Material(
      key: ObjectKey(item),
      color: bgColor,
      child: InkWell(
        onTap: isViewOnly ? null : () => _showEditItemDialog(context, cubit, index, item, state.products, state.currencyRate),
        onLongPress: isViewOnly ? null : () {
          showModalBottomSheet(context: context, builder: (_) => Column(mainAxisSize: MainAxisSize.min, children:[
            ListTile(leading: const Icon(Icons.card_giftcard), title: Text(item.isGift ? 'إلغاء الهدية' : 'جعل القلم هدية'), onTap: () { Navigator.pop(context); cubit.toggleGift(index); }),
            ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('حذف القلم', style: TextStyle(color: Colors.red)), onTap: () { Navigator.pop(context); cubit.removeItem(index); }),
          ]));
        },
        child: Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children:[
              // 1. الترتيب أو السحب
              Expanded(
                flex: 1,
                child: isViewOnly
                    ? Text('${index + 1}', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800))
                    : ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle, color: Colors.grey, size: 20),
                ),
              ),
              // 2. المادة
              Expanded(
                flex: 4,
                child: Text(item.isGift ? '$pName (هدية)' : pName, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: item.isGift ? Colors.indigo : Colors.black87)),
              ),
              // 3. الكمية
              Expanded(
                flex: 2,
                child: Text(_formatNum(item.quantity), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
              ),
              // 4. الوحدة
              Expanded(
                flex: 2,
                child: Text(item.unit, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ),
              // 5. الإفرادي
              Expanded(
                flex: 3,
                child: Text(item.isGift ? '0' : _formatNum(item.price), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
              ),
              // 6. الإجمالي
              Expanded(
                flex: 3,
                child: Text(item.isGift ? '0' : _formatNum(total), textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}