// lib/ui/screens/transactions/receipt_form_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/firestore_keys.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/transactions/receipt_form_cubit.dart';
import '../../../data/repositories/customers_repository.dart';
import '../../../data/repositories/transactions_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/receipt_model.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/models/unified_transaction.dart';

class ReceiptFormScreen extends StatefulWidget {
  final ReceiptModel? receiptToEdit;
  const ReceiptFormScreen({Key? key, this.receiptToEdit}) : super(key: key);

  @override
  State<ReceiptFormScreen> createState() => _ReceiptFormScreenState();
}

class _ReceiptFormScreenState extends State<ReceiptFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
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
    isViewMode = widget.receiptToEdit != null;
    if (isViewMode) {
      _amountController.text = _rawNum(widget.receiptToEdit!.amount);
      _noteController.text = widget.receiptToEdit!.lineNote;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, ReceiptFormCubit cubit) {
    showDialog(context: context, builder: (ctx) {
      return StreamBuilder<int>(
          stream: Stream.periodic(const Duration(seconds: 1), (i) => 3 - i - 1).take(3),
          builder: (context, snapshot) {
            final timeLeft = snapshot.data ?? 3;
            final isReady = timeLeft <= 0;
            return AlertDialog(
              title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.red)),
              content: const Text('هل أنت متأكد من حذف هذا السند نهائياً؟ سيتم عكس الأرصدة.'),
              actions:[
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: isReady ? () { cubit.deleteReceipt(widget.receiptToEdit!); Navigator.pop(ctx); } : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(isReady ? 'حذف السند' : 'حذف ($timeLeft)'),
                ),
              ],
            );
          }
      );
    });
  }

  // --- دالة حوار الطباعة والمشاركة (للسندات) ---
  void _showPrintShareDialog(BuildContext context, bool isShare, UserModel currentUser, List<CustomerModel> customers) {
    CustomerModel? c;
    if (widget.receiptToEdit != null) {
      try { c = customers.firstWhere((cust) => cust.id == widget.receiptToEdit!.creditorAccount); } catch(e){}
    }

    String defaultAddress = widget.receiptToEdit?.printAddress ?? '';
    if (defaultAddress.isEmpty && c != null) {
      List<String> addressParts =[];
      if (c.region.isNotEmpty) addressParts.add(c.region);
      if (c.district.isNotEmpty) addressParts.add(c.district);
      if (c.street.isNotEmpty) addressParts.add(c.street);
      defaultAddress = addressParts.join(' - ');
    }

    String defaultPhone = widget.receiptToEdit?.printPhone ?? '';
    if (defaultPhone.isEmpty && c != null) {
      defaultPhone = c.phone1.isNotEmpty ? c.phone1 : c.phone2;
    }

    final nameCtrl = TextEditingController(text: c?.customerName ?? '');
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
              TextField(controller: delegateCtrl, decoration: const InputDecoration(labelText: 'المندوب المستلم', border: OutlineInputBorder(), isDense: true)),
            ],
          ),
        ),
        actions:[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
            onPressed: () async {
              Navigator.pop(ctx);

              if (widget.receiptToEdit != null) {
                context.read<TransactionsRepository>().savePrintData(
                    FirestoreKeys.receipts, widget.receiptToEdit!.id, addressCtrl.text.trim(), phoneCtrl.text.trim()
                );
              }

              if (isShare) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تجهيز الصورة...')));
                final widgetToCapture = Theme(
                  data: ThemeData.light(),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(color: Colors.white, child: _buildReceiptWidgetForImage(nameCtrl.text, addressCtrl.text, phoneCtrl.text, delegateCtrl.text)),
                  ),
                );
                try {
                  final bytes = await _screenshotController.captureFromWidget(widgetToCapture, delay: const Duration(milliseconds: 300));
                  final directory = await getApplicationDocumentsDirectory();
                  final imagePath = '${directory.path}/receipt_${widget.receiptToEdit?.delegateReceiptNumber ?? 'new'}.png';
                  File(imagePath).writeAsBytesSync(bytes);
                  await Share.shareXFiles([XFile(imagePath)], text: 'مرفق صورة السند');
                } catch(e) {}
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري الاتصال بالطابعة...')));
                final t = UnifiedTransaction(
                    id: widget.receiptToEdit!.id, type: TransactionType.receipt, date: widget.receiptToEdit!.date, updatedAt: widget.receiptToEdit!.updatedAt,
                    localNumber: widget.receiptToEdit!.delegateReceiptNumber, globalNumber: widget.receiptToEdit!.receiptNumber,
                    customerName: nameCtrl.text, amount: widget.receiptToEdit!.amount, isSynced: true, delegateId: currentUser.id,
                    delegateName: delegateCtrl.text, delegateColor: '#000000', delegateSuffix: '', paymentMethod: 'cash', showModifiedDate: false, originalDoc: widget.receiptToEdit!
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

  Widget _buildReceiptWidgetForImage(String cName, String cAddress, String cPhone, String dName) {
    return Container(
      width: 400, padding: const EdgeInsets.all(16), color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          const Text('المالك الأمين للبهارات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('سند قبض رقم: ${widget.receiptToEdit?.delegateReceiptNumber ?? ''}'),
          const Divider(thickness: 2),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[Text('الزبون: $cName'), Text('التاريخ: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}')]),
          if(cAddress.isNotEmpty) Row(children:[Text('العنوان: $cAddress')]),
          if(cPhone.isNotEmpty) Row(children:[Text('الهاتف: $cPhone')]),
          if(dName.isNotEmpty) Row(children:[Text('المندوب المستلم: $dName')]),
          const Divider(thickness: 2),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              const Text('المبلغ المقبوض:', style: TextStyle(fontSize: 18)),
              Text('${_formatNum(widget.receiptToEdit!.amount)} ل.س', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.receiptToEdit!.lineNote.isNotEmpty)
            Row(children:[Expanded(child: Text('البيان: ${widget.receiptToEdit!.lineNote}', style: const TextStyle(fontSize: 16)))]),
          const SizedBox(height: 16),
          const Divider(thickness: 2),
          const Text('توقيع المستلم', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final currentUser = authState.user;

    final isMine = widget.receiptToEdit == null || widget.receiptToEdit!.delegateId == currentUser.id;
    final canEdit = (isMine && currentUser.permissions.receiptEdit) || (!isMine && currentUser.permissions.receiptEditMonitored);
    final canDelete = (isMine && currentUser.permissions.receiptDelete) || (!isMine && currentUser.permissions.receiptDeleteMonitored);

    return BlocProvider(
      create: (context) => ReceiptFormCubit(
        context.read<CustomersRepository>(),
        context.read<TransactionsRepository>(),
        currentUser,
      )..initData(receiptToEdit: widget.receiptToEdit),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isViewMode ? 'عرض سند قبض #${widget.receiptToEdit!.delegateReceiptNumber}' : (widget.receiptToEdit != null ? 'تعديل السند' : 'إنشاء سند قبض')),
          centerTitle: true,
          backgroundColor: isViewMode ? Colors.grey.shade700 : Colors.green.shade600,
          foregroundColor: Colors.white,
          actions: isViewMode ?[
            BlocBuilder<ReceiptFormCubit, ReceiptFormState>(
                builder: (context, state) {
                  if (state is ReceiptFormReady) {
                    return PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') setState(() => isViewMode = false);
                        if (val == 'delete') _showDeleteDialog(context, context.read<ReceiptFormCubit>());
                        if (val == 'print') _showPrintShareDialog(context, false, currentUser.accountName as UserModel, state.customers);
                        if (val == 'share') _showPrintShareDialog(context, true, currentUser.accountName as UserModel, state.customers);
                      },
                      itemBuilder: (ctx) =>[
                        const PopupMenuItem(value: 'print', child: Row(children:[Icon(Icons.print), SizedBox(width: 8), Text('طباعة حرارية')])),
                        const PopupMenuItem(value: 'share', child: Row(children:[Icon(Icons.share), SizedBox(width: 8), Text('مشاركة صورة السند')])),
                        if (canEdit) const PopupMenuDivider(),
                        if (canEdit) const PopupMenuItem(value: 'edit', child: Row(children:[Icon(Icons.edit), SizedBox(width: 8), Text('تعديل السند')])),
                        if (canDelete) const PopupMenuItem(value: 'delete', child: Row(children:[Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('حذف السند', style: TextStyle(color: Colors.red))])),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }
            )
          ] : null,
        ),
        body: BlocConsumer<ReceiptFormCubit, ReceiptFormState>(
          listener: (context, state) {
            if (state is ReceiptFormSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت العملية بنجاح'), backgroundColor: Colors.green));
              context.pop();
            } else if (state is ReceiptFormError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state is ReceiptFormLoading || state is ReceiptFormInitial) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            }
            if (state is ReceiptFormError) {
              return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[const Icon(Icons.error_outline, color: Colors.red, size: 80), const SizedBox(height: 16), Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center)])));
            }
            if (state is ReceiptFormReady) {
              final cubit = context.read<ReceiptFormCubit>();

              // إذا كنا في وضع العرض وبدون زبون محدد مسبقاً، نحاول إيجاده لعرض اسمه
              if (isViewMode && _selectedCustomer == null && widget.receiptToEdit!.creditorAccount.isNotEmpty) {
                try { _selectedCustomer = state.customers.firstWhere((c) => c.id == widget.receiptToEdit!.creditorAccount); } catch(e){}
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:[
                      // بحث الزبائن الذكي (Autocomplete)
                      Autocomplete<CustomerModel>(
                        initialValue: TextEditingValue(text: _selectedCustomer != null ? _cleanCustomerName(_selectedCustomer!.customerName, currentUser.customerSuffix) : ''),
                        displayStringForOption: (c) => _cleanCustomerName(c.customerName, currentUser.customerSuffix),
                        optionsBuilder: (textEditingValue) {
                          if (isViewMode) return const Iterable<CustomerModel>.empty(); // في العرض نعطل القائمة
                          if (textEditingValue.text.isEmpty) return state.customers;
                          return state.customers.where((c) => _cleanCustomerName(c.customerName, currentUser.customerSuffix).toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (c) => _selectedCustomer = c,
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            readOnly: isViewMode, // قراءة فقط في وضع العرض
                            decoration: InputDecoration(
                              labelText: 'الزبون الذي دفع المبلغ',
                              border: const OutlineInputBorder(),
                              filled: isViewMode,
                              prefixIcon: const Icon(Icons.person),
                              suffixIcon: isViewMode ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () { controller.clear(); _selectedCustomer = null; }),
                            ),
                            validator: (val) => _selectedCustomer == null ? 'الرجاء اختيار الزبون' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        readOnly: isViewMode,
                        decoration: InputDecoration(
                          labelText: 'المبلغ المقبوض',
                          border: const OutlineInputBorder(),
                          filled: isViewMode,
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'الرجاء إدخال المبلغ';
                          final d = double.tryParse(val.replaceAll(',', ''));
                          if (d == null) return 'قيمة غير صالحة';
                          if (d <= 0) return 'لا يمكن أن يكون المبلغ صفراً أو سالباً';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _noteController,
                        readOnly: isViewMode,
                        decoration: InputDecoration(
                          labelText: 'البيان (ملاحظات السند)',
                          border: const OutlineInputBorder(),
                          filled: isViewMode,
                          prefixIcon: const Icon(Icons.notes),
                        ),
                      ),
                      const SizedBox(height: 32),

                      if (!isViewMode)
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() && _selectedCustomer != null) {
                              cubit.submitReceipt(
                                selectedCustomer: _selectedCustomer!,
                                amount: double.parse(_amountController.text.trim()),
                                note: _noteController.text.trim(),
                                oldReceipt: widget.receiptToEdit,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green.shade700,
                          ),
                          child: const Text('حفظ السند واعتماده', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}