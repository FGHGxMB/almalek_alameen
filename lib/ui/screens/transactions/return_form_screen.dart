// lib/ui/screens/transactions/return_form_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spice_app/core/constants/firestore_keys.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/transactions/return_form_cubit.dart';
import '../../../data/repositories/customers_repository.dart';
import '../../../data/repositories/products_repository.dart';
import '../../../data/repositories/transactions_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/return_model.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/product_selection_grid.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/models/unified_transaction.dart';

class ReturnFormScreen extends StatefulWidget {
  final ReturnModel? returnToEdit;
  const ReturnFormScreen({Key? key, this.returnToEdit}) : super(key: key);
  @override
  State<ReturnFormScreen> createState() => _ReturnFormScreenState();
}

class _ReturnFormScreenState extends State<ReturnFormScreen> {
  final _noteController = TextEditingController();
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
    isViewMode = widget.returnToEdit != null;
    if (isViewMode) {
      _noteController.text = widget.returnToEdit!.returnNote;
    }
  }

  void _showDeleteDialog(BuildContext context, ReturnFormCubit cubit) {
    showDialog(context: context, builder: (ctx) {
      return StreamBuilder<int>(
          stream: Stream.periodic(const Duration(seconds: 1), (i) => 3 - i - 1).take(3),
          builder: (context, snapshot) {
            final timeLeft = snapshot.data ?? 3;
            final isReady = timeLeft <= 0;
            return AlertDialog(
              title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.red)),
              content: const Text('هل أنت متأكد من حذف هذا المرتجع نهائياً؟ سيتم عكس الأرصدة.'),
              actions:[
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: isReady ? () { cubit.deleteReturn(widget.returnToEdit!); Navigator.pop(ctx); } : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(isReady ? 'حذف المرتجع' : 'حذف ($timeLeft)'),
                ),
              ],
            );
          }
      );
    });
  }

  // --- دالة حوار الطباعة والمشاركة ---
  // --- دالة حوار الطباعة والمشاركة (للمرتجعات) ---
  void _showPrintShareDialog(BuildContext context, ReturnFormReady state, bool isShare, UserModel currentUser) {
    CustomerModel? c;
    try { c = state.myCustomers.firstWhere((cust) => cust.id == widget.returnToEdit!.customerId); } catch(e){}

    String defaultAddress = widget.returnToEdit!.printAddress;
    if (defaultAddress.isEmpty && c != null) {
      List<String> addressParts =[];
      if (c.region.isNotEmpty) addressParts.add(c.region);
      if (c.district.isNotEmpty) addressParts.add(c.district);
      if (c.street.isNotEmpty) addressParts.add(c.street);
      defaultAddress = addressParts.join(' - ');
    }

    String defaultPhone = widget.returnToEdit!.printPhone;
    if (defaultPhone.isEmpty && c != null) {
      defaultPhone = c.phone1.isNotEmpty ? c.phone1 : c.phone2;
    }

    final nameCtrl = TextEditingController(text: widget.returnToEdit?.customerName ?? '');
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () async {
              Navigator.pop(ctx);

              // حفظ بيانات الطباعة في السيرفر
              context.read<TransactionsRepository>().savePrintData(
                  FirestoreKeys.returns, widget.returnToEdit!.id, addressCtrl.text.trim(), phoneCtrl.text.trim()
              );

              if (isShare) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تجهيز الصورة...')));
                final widgetToCapture = Theme(
                  data: ThemeData.light(),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(color: Colors.white, child: _buildReceiptWidgetForImage(state, nameCtrl.text, addressCtrl.text, phoneCtrl.text, delegateCtrl.text)),
                  ),
                );
                try {
                  final bytes = await _screenshotController.captureFromWidget(widgetToCapture, delay: const Duration(milliseconds: 300));
                  final directory = await getApplicationDocumentsDirectory();
                  final imagePath = '${directory.path}/return_${widget.returnToEdit?.delegateReturnNumber ?? 'new'}.png';
                  File(imagePath).writeAsBytesSync(bytes);
                  await Share.shareXFiles([XFile(imagePath)], text: 'مرفق صورة المرتجع');
                } catch(e) {}
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري الاتصال بالطابعة...')));
                final t = UnifiedTransaction(
                    id: widget.returnToEdit!.id, type: TransactionType.returnDoc, date: widget.returnToEdit!.returnDate, updatedAt: widget.returnToEdit!.updatedAt,
                    localNumber: widget.returnToEdit!.delegateReturnNumber, globalNumber: widget.returnToEdit!.returnNumber,
                    customerId: widget.returnToEdit!.customerId, // <--- السطر المضاف
                    customerName: nameCtrl.text, amount: state.total, isSynced: true, delegateId: currentUser.id,
                    delegateName: delegateCtrl.text, delegateColor: '#000000', delegateSuffix: '', paymentMethod: state.paymentMethod, showModifiedDate: false, originalDoc: widget.returnToEdit!
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

  Widget _buildReceiptWidgetForImage(ReturnFormReady state, String cName, String cAddress, String cPhone, String dName) {
    return Container(
      width: 400, padding: const EdgeInsets.all(16), color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          const Text('المالك الأمين للبهارات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('مرتجع مبيعات رقم: ${widget.returnToEdit?.delegateReturnNumber.toString().padLeft(5, '0') ?? ''}'),
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
                  return TableRow(children:[Text(pName), Text('${_formatNum(i.quantity)} ${i.unit}'), Text(_formatNum(i.quantity*i.price))]);
                }).toList(),
              ]
          ),
          const Divider(thickness: 2),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text('الصافي النهائي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(_formatNum(state.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, ReturnFormCubit cubit, int index, var item, List<ProductModel> products, double currencyRate) {
    if (item.isGift) return;

    final product = products.firstWhere((p) => p.id == item.productId);
    double qty = item.quantity;
    String u = item.unit;
    double price = item.price;

    final qtyCtrl = TextEditingController(text: _rawNum(qty));
    final priceCtrl = TextEditingController(text: _rawNum(price));

    String? qtyError;
    String? priceError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('تعديل ${product.itemName}', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
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
                          if (v == product.unit1) { price = product.shopPrice1 * currencyRate; }
                          if (v == product.unit2) { price = product.shopPrice2 * currencyRate; }
                          if (v == product.unit3) { price = product.shopPrice3 * currencyRate; }
                          priceCtrl.text = _rawNum(price);
                          priceError = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'السعر الإفرادي',
                      border: const OutlineInputBorder(),
                      errorText: priceError,
                      suffixIcon: IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { priceCtrl.clear(); setState(() => price = 0); }),
                    ),
                    onChanged: (v) {
                      setState(() {
                        price = double.tryParse(v) ?? 0;
                        priceError = price <= 0 ? 'لا يمكن أن يكون صفراً أو سالباً' : null;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions:[
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    qtyError = qty <= 0 ? 'لا يمكن أن تكون صفراً أو سالبة' : null;
                    priceError = price <= 0 ? 'لا يمكن أن يكون صفراً أو سالباً' : null;
                  });

                  if (qtyError == null && priceError == null) {
                    cubit.updateItem(index, qty, u, price);
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
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

    final isMine = widget.returnToEdit == null || widget.returnToEdit!.delegateId == currentUser.id;
    final canEdit = (isMine && currentUser.permissions.returnEdit) || (!isMine && currentUser.permissions.returnEditMonitored);
    final canDelete = (isMine && currentUser.permissions.returnDelete) || (!isMine && currentUser.permissions.returnDeleteMonitored);

    return BlocProvider(
      create: (context) => ReturnFormCubit(context.read<CustomersRepository>(), context.read<ProductsRepository>(), context.read<TransactionsRepository>(), currentUser)..initData(returnToEdit: widget.returnToEdit),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isViewMode ? 'عرض مرتجع #${widget.returnToEdit!.delegateReturnNumber.toString().padLeft(5, '0')}' : (widget.returnToEdit != null ? 'تعديل مرتجع' : 'إنشاء مرتجع')),
          centerTitle: true,
          backgroundColor: isViewMode ? Colors.grey.shade700 : Colors.red.shade700,
          foregroundColor: Colors.white,
          actions: isViewMode ?[
            BlocBuilder<ReturnFormCubit, ReturnFormState>(
                builder: (context, state) {
                  if (state is ReturnFormReady) {
                    return PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') setState(() => isViewMode = false);
                        if (val == 'delete') _showDeleteDialog(context, context.read<ReturnFormCubit>());
                        if (val == 'print') _showPrintShareDialog(context, state, false, currentUser);
                        if (val == 'share') _showPrintShareDialog(context, state, true, currentUser);
                      },
                      itemBuilder: (ctx) =>[
                        const PopupMenuItem(value: 'print', child: Row(children:[Icon(Icons.print), SizedBox(width: 8), Text('طباعة حرارية')])),
                        const PopupMenuItem(value: 'share', child: Row(children:[Icon(Icons.share), SizedBox(width: 8), Text('مشاركة صورة المرتجع')])),
                        if (canEdit) const PopupMenuDivider(),
                        if (canEdit) const PopupMenuItem(value: 'edit', child: Row(children:[Icon(Icons.edit), SizedBox(width: 8), Text('تعديل المرتجع')])),
                        if (canDelete) const PopupMenuItem(value: 'delete', child: Row(children:[Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('حذف المرتجع', style: TextStyle(color: Colors.red))])),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }
            )
          ] : null,
        ),
        body: BlocConsumer<ReturnFormCubit, ReturnFormState>(
          listener: (context, state) {
            if (state is ReturnFormSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت العملية بنجاح'), backgroundColor: Colors.green));
              context.pop();
            } else if (state is ReturnFormError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state is ReturnFormLoading || state is ReturnFormInitial) return const Center(child: CircularProgressIndicator(color: Colors.red));

            // أضفنا هذا القسم لمنع الشاشة البيضاء
            if (state is ReturnFormError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      const Icon(Icons.error_outline, color: Colors.red, size: 80),
                      const SizedBox(height: 16),
                      Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }

            if (state is ReturnFormReady) {
              final cubit = context.read<ReturnFormCubit>();

              if (isViewMode && _selectedCustomer == null && widget.returnToEdit!.customerId.isNotEmpty) {
                try { _selectedCustomer = state.myCustomers.firstWhere((c) => c.id == widget.returnToEdit!.customerId); } catch(e){}
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
                                  initialValue: TextEditingValue(text: _selectedCustomer != null ? _cleanCustomerName(_selectedCustomer!.customerName, currentUser.customerSuffix) : (isViewMode ? _cleanCustomerName(widget.returnToEdit!.customerName, currentUser.customerSuffix) : '')),
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
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(labelText: 'النوع', border: const OutlineInputBorder(), isDense: true, filled: isViewMode),
                                  value: state.paymentMethod,
                                  items: const[DropdownMenuItem(value: 'cash', child: Text('نقدي (رد مبلغ)')), DropdownMenuItem(value: 'credit', child: Text('آجل (خصم ذمة)'))],
                                  onChanged: isViewMode ? null : (val) => cubit.updatePaymentMethod(val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(controller: _noteController, readOnly: isViewMode, decoration: InputDecoration(labelText: 'البيان', border: const OutlineInputBorder(), isDense: true, filled: isViewMode)),

                          const Divider(height: 32, thickness: 2),

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
                                        isReturn: true,
                                        onProductAdded: (p, q, u, pr, g) => cubit.addItem(p, q, u, pr, g), // في المرتجع المتغير الأخير isGift سيكون دائماً false داخل الـ Grid
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                                  label: const Text('إضافة', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, padding: const EdgeInsets.symmetric(horizontal: 12)),
                                )
                            ],
                          ),
                          const SizedBox(height: 8),

                          Expanded(
                            child: Column(
                              children:[
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                                  child: Row(
                                    children:[
                                      Expanded(flex: 1, child: Text(isViewMode ? '#' : 'ترتيب', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                                      const Expanded(flex: 4, child: Text('المادة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                                      const Expanded(flex: 2, child: Text('الكمية', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                                      const Expanded(flex: 2, child: Text('الوحدة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                                      const Expanded(flex: 3, child: Text('الإفرادي', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                                      const Expanded(flex: 3, child: Text('الإجمالي', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: state.items.isEmpty
                                      ? Container(width: double.infinity, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8))), child: const Center(child: Text('المرتجع فارغ', style: TextStyle(color: Colors.grey))))
                                      : Container(
                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8))),
                                    child: isViewMode
                                        ? ListView.builder(itemCount: state.items.length, itemBuilder: (context, index) => _buildItemRow(context, cubit, state, index, true))
                                        : ReorderableListView.builder(buildDefaultDragHandles: false, itemCount: state.items.length, onReorder: (oldIdx, newIdx) => cubit.reorderItems(oldIdx, newIdx), itemBuilder: (context, index) => _buildItemRow(context, cubit, state, index, false)),
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
                    padding: const EdgeInsets.all(16), color: Colors.red.shade50,
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Text('إجمالي المرتجع: ${_formatNum(state.total)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade800)),
                          if (!isViewMode)
                            ElevatedButton(
                              onPressed: () => cubit.submitReturn(selectedCustomer: _selectedCustomer, note: _noteController.text.trim(), oldReturn: widget.returnToEdit),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
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

  Widget _buildItemRow(BuildContext context, ReturnFormCubit cubit, ReturnFormReady state, int index, bool isViewOnly) {
    final item = state.items[index];
    final pName = state.products.firstWhere((p) => p.id == item.productId).itemName;
    final total = item.quantity * item.price;

    Color bgColor = index % 2 == 0 ? Colors.white : Colors.grey.shade50;

    return Material(
      key: ObjectKey(item),
      color: bgColor,
      child: InkWell(
        onTap: isViewOnly ? null : () => _showEditItemDialog(context, cubit, index, item, state.products, state.currencyRate),
        onLongPress: isViewOnly ? null : () {
          showModalBottomSheet(context: context, builder: (_) => Column(mainAxisSize: MainAxisSize.min, children:[
            ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('حذف القلم', style: TextStyle(color: Colors.red)), onTap: () { Navigator.pop(context); cubit.removeItem(index); }),
          ]));
        },
        child: Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children:[
              Expanded(flex: 1, child: isViewOnly ? Text('${index + 1}', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade800)) : ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle, color: Colors.grey, size: 20))),
              Expanded(flex: 4, child: Text(pName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87))),
              Expanded(flex: 2, child: Text(_formatNum(item.quantity), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
              Expanded(flex: 2, child: Text(item.unit, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.blueGrey))),
              Expanded(flex: 3, child: Text(_formatNum(item.price), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
              Expanded(flex: 3, child: Text(_formatNum(total), textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade800))),
            ],
          ),
        ),
      ),
    );
  }
}