// lib/ui/widgets/transaction_filters_panel.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../logic/transactions/transactions_cubit.dart';
import '../../data/models/user_model.dart';
import '../../data/models/customer_model.dart';

class TransactionFiltersPanel extends StatefulWidget {
  final TransactionFilters currentFilters;
  final Map<String, UserModel> usersMap;
  final List<CustomerModel> customers;
  final UserModel currentUser;
  final Function(TransactionFilters) onApply;
  final VoidCallback onReset;

  const TransactionFiltersPanel({
    Key? key, required this.currentFilters, required this.usersMap,
    required this.customers, required this.currentUser,
    required this.onApply, required this.onReset,
  }) : super(key: key);

  @override
  State<TransactionFiltersPanel> createState() => _TransactionFiltersPanelState();
}

class _TransactionFiltersPanelState extends State<TransactionFiltersPanel> {
  late TransactionFilters _draft;
  final _minController = TextEditingController();
  final _maxController = TextEditingController();

  String _cleanCustomerName(String fullName, String suffix) {
    if (suffix.isNotEmpty && fullName.startsWith(suffix)) {
      return fullName.replaceFirst(suffix, '').trim();
    }
    return fullName;
  }

  @override
  void initState() {
    super.initState();
    _draft = TransactionFilters.fromJson(widget.currentFilters.toJson());
    if (_draft.minAmount != null) _minController.text = _draft.minAmount.toString();
    if (_draft.maxAmount != null) _maxController.text = _draft.maxAmount.toString();
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) _draft.fromDate = picked; else _draft.toDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + bottomInset),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children:[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              const Text('فلاتر وترتيب المعاملات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children:[
                const Text('1. ترتيب القائمة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Card(
                  elevation: 0, color: Colors.teal.shade50,
                  child: Column(
                    children:[
                      RadioListTile<String>(title: const Text('حسب تاريخ الإنشاء (الأحدث) - افتراضي'), value: 'date_desc', groupValue: _draft.sortMode, onChanged: (v) => setState(() => _draft.sortMode = v!)),
                      RadioListTile<String>(title: const Text('من الأعلى قيمة للأقل'), value: 'value_desc', groupValue: _draft.sortMode, onChanged: (v) => setState(() => _draft.sortMode = v!)),
                      RadioListTile<String>(title: const Text('من الأقل قيمة للأعلى'), value: 'value_asc', groupValue: _draft.sortMode, onChanged: (v) => setState(() => _draft.sortMode = v!)),
                      const Divider(height: 1),
                      CheckboxListTile(title: const Text('تجميع حسب الحساب المسؤول أولاً'), value: _draft.sortByDelegate, onChanged: (v) => setState(() => _draft.sortByDelegate = v!)),
                      CheckboxListTile(title: const Text('تجميع حسب نوع الدفع (نقدي/آجل/هدية)'), value: _draft.sortByPayment, onChanged: (v) => setState(() => _draft.sortByPayment = v!)),
                      CheckboxListTile(title: const Text('تجميع حسب نوع الوثيقة (فاتورة/مرتجع/سند)'), value: _draft.sortByDocType, onChanged: (v) => setState(() => _draft.sortByDocType = v!)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text('2. إظهار وإخفاء (تصفية)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),

                // فلتر الزبائن والنقدي (الجديد)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children:[
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('عرض العمليات النقدية فقط (بدون زبون)', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                          value: _draft.filterCashOnly,
                          onChanged: (v) {
                            setState(() {
                              _draft.filterCashOnly = v!;
                              if (v) {
                                _draft.selectedCustomerId = null;
                                _draft.selectedCustomerName = null;
                              }
                            });
                          }
                      ),
                      if (!_draft.filterCashOnly)
                        Autocomplete<CustomerModel>(
                          initialValue: TextEditingValue(text: _draft.selectedCustomerName ?? ''),
                          displayStringForOption: (c) => _cleanCustomerName(c.customerName, widget.currentUser.customerSuffix),
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text.isEmpty) return widget.customers;
                            return widget.customers.where((c) => _cleanCustomerName(c.customerName, widget.currentUser.customerSuffix).toLowerCase().contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (c) {
                            setState(() {
                              _draft.selectedCustomerId = c.id;
                              _draft.selectedCustomerName = _cleanCustomerName(c.customerName, widget.currentUser.customerSuffix);
                            });
                          },
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: controller, focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'البحث عن زبون محدد لعرض حركاته', border: const OutlineInputBorder(), isDense: true,
                                suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () {
                                  controller.clear();
                                  setState(() { _draft.selectedCustomerId = null; _draft.selectedCustomerName = null; });
                                }),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children:[
                      Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.date_range, size: 16), label: Text(_draft.fromDate == null ? 'من تاريخ' : DateFormat('yyyy-MM-dd').format(_draft.fromDate!)), onPressed: () => _selectDate(context, true))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.date_range, size: 16), label: Text(_draft.toDate == null ? 'إلى تاريخ' : DateFormat('yyyy-MM-dd').format(_draft.toDate!)), onPressed: () => _selectDate(context, false))),
                    ],
                  ),
                ),

                ExpansionTile(
                  title: const Text('الحساب المسؤول (المندوب)'),
                  subtitle: Text('${_draft.selectedDelegates.length} محدد'),
                  children: widget.usersMap.keys.map((dId) {
                    final name = widget.usersMap[dId]?.accountName ?? 'مجهول';
                    return CheckboxListTile(title: Text(name), value: _draft.selectedDelegates.contains(dId), onChanged: (v) { setState(() { if (v == true) _draft.selectedDelegates.add(dId); else _draft.selectedDelegates.remove(dId); }); });
                  }).toList(),
                ),

                ExpansionTile(
                  title: const Text('نوع الدفع / الفاتورة'),
                  subtitle: Text(_draft.selectedPaymentMethods.isEmpty ? 'الكل' : '${_draft.selectedPaymentMethods.length} محدد'),
                  children:[
                    CheckboxListTile(title: const Text('نقدية'), value: _draft.selectedPaymentMethods.contains('cash'), onChanged: (v) { setState(() { if (v == true) _draft.selectedPaymentMethods.add('cash'); else _draft.selectedPaymentMethods.remove('cash'); }); }),
                    CheckboxListTile(title: const Text('آجلة (ذمم)'), value: _draft.selectedPaymentMethods.contains('credit'), onChanged: (v) { setState(() { if (v == true) _draft.selectedPaymentMethods.add('credit'); else _draft.selectedPaymentMethods.remove('credit'); }); }),
                    CheckboxListTile(title: const Text('هدايا'), value: _draft.selectedPaymentMethods.contains('gift'), onChanged: (v) { setState(() { if (v == true) _draft.selectedPaymentMethods.add('gift'); else _draft.selectedPaymentMethods.remove('gift'); }); }),
                  ],
                ),

                ExpansionTile(
                  title: const Text('نوع الوثيقة'),
                  subtitle: Text(_draft.selectedDocTypes.isEmpty ? 'الكل' : '${_draft.selectedDocTypes.length} محدد'),
                  children:[
                    CheckboxListTile(title: const Text('فاتورة مبيعات'), value: _draft.selectedDocTypes.contains('invoice'), onChanged: (v) { setState(() { if (v == true) _draft.selectedDocTypes.add('invoice'); else _draft.selectedDocTypes.remove('invoice'); }); }),
                    CheckboxListTile(title: const Text('مرتجع مبيعات'), value: _draft.selectedDocTypes.contains('return'), onChanged: (v) { setState(() { if (v == true) _draft.selectedDocTypes.add('return'); else _draft.selectedDocTypes.remove('return'); }); }),
                    CheckboxListTile(title: const Text('سند قبض'), value: _draft.selectedDocTypes.contains('receipt'), onChanged: (v) { setState(() { if (v == true) _draft.selectedDocTypes.add('receipt'); else _draft.selectedDocTypes.remove('receipt'); }); }),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    children:[
                      Expanded(child: TextField(controller: _minController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قيمة أعلى من', isDense: true))),
                      const SizedBox(width: 16),
                      Expanded(child: TextField(controller: _maxController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قيمة أقل من', isDense: true))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            children:[
              Expanded(child: OutlinedButton(onPressed: () { widget.onReset(); Navigator.pop(context); }, child: const Text('إرجاع للافتراضي'))),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    _draft.minAmount = double.tryParse(_minController.text);
                    _draft.maxAmount = double.tryParse(_maxController.text);
                    widget.onApply(_draft);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text('تطبيق الفلاتر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}