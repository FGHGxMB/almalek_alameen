// lib/ui/widgets/customer_filters_panel.dart
import 'package:flutter/material.dart';
import '../../logic/customers/customers_cubit.dart';
import '../../data/models/user_model.dart';

class CustomerFiltersPanel extends StatefulWidget {
  final CustomerFilters currentFilters;
  final List<String> availableAreas;
  final Map<String, UserModel> usersMap;
  final Function(CustomerFilters) onApply;
  final VoidCallback onReset;

  const CustomerFiltersPanel({
    Key? key, required this.currentFilters, required this.availableAreas,
    required this.usersMap, required this.onApply, required this.onReset,
  }) : super(key: key);

  @override
  State<CustomerFiltersPanel> createState() => _CustomerFiltersPanelState();
}

class _CustomerFiltersPanelState extends State<CustomerFiltersPanel> {
  late CustomerFilters _draft;
  final _minController = TextEditingController();
  final _maxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = CustomerFilters.fromJson(widget.currentFilters.toJson());
    if (_draft.minBalance != null) _minController.text = _draft.minBalance.toString();
    if (_draft.maxBalance != null) _maxController.text = _draft.maxBalance.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children:[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              const Text('فلاتر وترتيب الزبائن', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
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
                      RadioListTile<String>(title: const Text('حسب آخر حركة (الأحدث)'), value: 'last_transaction', groupValue: _draft.sortMode, onChanged: (v) => setState(() => _draft.sortMode = v!)),
                      RadioListTile<String>(title: const Text('الرصيد: من الأعلى للأقل'), value: 'balance_desc', groupValue: _draft.sortMode, onChanged: (v) => setState(() => _draft.sortMode = v!)),
                      RadioListTile<String>(title: const Text('الرصيد: من الأقل للأعلى'), value: 'balance_asc', groupValue: _draft.sortMode, onChanged: (v) => setState(() => _draft.sortMode = v!)),
                      const Divider(height: 1),
                      CheckboxListTile(title: const Text('تجميع وترتيب حسب المنطقة أولاً'), value: _draft.sortByRegion, onChanged: (v) => setState(() => _draft.sortByRegion = v!)),
                      CheckboxListTile(title: const Text('تجميع وترتيب حسب المندوب (الحساب) أولاً'), value: _draft.sortByDelegate, onChanged: (v) => setState(() => _draft.sortByDelegate = v!)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('2. إظهار وإخفاء (تصفية)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),

                ExpansionTile(
                  title: const Text('الحساب المسؤول (المندوب)'),
                  subtitle: Text('${_draft.selectedDelegates.length} محدد'),
                  children: widget.usersMap.keys.map((dId) {
                    final name = widget.usersMap[dId]?.accountName ?? 'مجهول';
                    return CheckboxListTile(
                      title: Text(name),
                      value: _draft.selectedDelegates.contains(dId),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) _draft.selectedDelegates.add(dId);
                          else _draft.selectedDelegates.remove(dId);
                        });
                      },
                    );
                  }).toList(),
                ),

                ExpansionTile(
                  title: const Text('المنطقة'),
                  subtitle: Text(_draft.selectedRegions.isEmpty ? 'الكل' : '${_draft.selectedRegions.length} محدد'),
                  children:[
                    CheckboxListTile(
                      title: const Text('تحديد الكل / إلغاء تحديد الكل', style: TextStyle(fontWeight: FontWeight.bold)),
                      value: _draft.selectedRegions.length == widget.availableAreas.length,
                      onChanged: (v) { setState(() { if (v == true) _draft.selectedRegions = List.from(widget.availableAreas); else _draft.selectedRegions.clear(); }); },
                    ),
                    ...widget.availableAreas.map((a) {
                      return CheckboxListTile(title: Text(a), value: _draft.selectedRegions.contains(a), onChanged: (v) { setState(() { if (v == true) _draft.selectedRegions.add(a); else _draft.selectedRegions.remove(a); }); });
                    }).toList(),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children:[
                      Expanded(child: TextField(controller: _minController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'رصيد أكبر من', isDense: true))),
                      const SizedBox(width: 16),
                      Expanded(child: TextField(controller: _maxController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'رصيد أقل من', isDense: true))),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String?>(
                    value: _draft.balanceState,
                    decoration: const InputDecoration(labelText: 'حالة الرصيد', isDense: true),
                    items: const[
                      DropdownMenuItem(value: null, child: Text('الكل')),
                      DropdownMenuItem(value: 'has_debt', child: Text('عليه ديون (سالب)')),
                      DropdownMenuItem(value: 'zero', child: Text('مصفر (صفر)')),
                      DropdownMenuItem(value: 'creditor', child: Text('له رصيد (موجب)')),
                    ],
                    onChanged: (v) => setState(() => _draft.balanceState = v),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String?>(
                    value: _draft.gender,
                    decoration: const InputDecoration(labelText: 'الجنس', isDense: true),
                    items: const[
                      DropdownMenuItem(value: null, child: Text('الكل')),
                      DropdownMenuItem(value: 'male', child: Text('الذكور فقط')),
                      DropdownMenuItem(value: 'female', child: Text('الإناث فقط')),
                    ],
                    onChanged: (v) => setState(() => _draft.gender = v),
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
                    _draft.minBalance = double.tryParse(_minController.text);
                    _draft.maxBalance = double.tryParse(_maxController.text);
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