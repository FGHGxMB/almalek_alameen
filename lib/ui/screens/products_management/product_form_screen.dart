// lib/ui/screens/products_management/product_form_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/products_repository.dart';
import '../../../logic/products_management/products_management_cubit.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? productToEdit;
  final String initialTab;
  final int initialCol;
  final int initialRow;

  const ProductFormScreen({Key? key, this.productToEdit, this.initialTab = '', this.initialCol = 0, this.initialRow = 0}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl; late TextEditingController _codeCtrl;
  late TextEditingController _tabCtrl; late TextEditingController _colCtrl;

  late TextEditingController _unit1Ctrl; late TextEditingController _price1Ctrl; late TextEditingController _minPrice1Ctrl; late TextEditingController _costPrice1Ctrl; String _cur1 = 'USD';
  late TextEditingController _unit2Ctrl; late TextEditingController _price2Ctrl; late TextEditingController _minPrice2Ctrl; late TextEditingController _costPrice2Ctrl; String _cur2 = 'USD';
  late TextEditingController _unit3Ctrl; late TextEditingController _price3Ctrl; late TextEditingController _minPrice3Ctrl; late TextEditingController _costPrice3Ctrl; String _cur3 = 'USD';

  bool _isActive = true;
  int _defaultUnitIndex = 1;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _nameCtrl = TextEditingController(text: p?.itemName ?? '');
    _codeCtrl = TextEditingController(text: p?.itemCode ?? '');
    _tabCtrl = TextEditingController(text: p?.tabName ?? widget.initialTab);
    _colCtrl = TextEditingController(text: (p?.columnIndex ?? widget.initialCol).toString());

    _unit1Ctrl = TextEditingController(text: p?.unit1 ?? 'حبة');
    _price1Ctrl = TextEditingController(text: p?.shopPrice1.toString() ?? '0');
    _minPrice1Ctrl = TextEditingController(text: p?.minPrice1.toString() ?? '0');
    _costPrice1Ctrl = TextEditingController(text: p?.costPrice1.toString() ?? '0');
    _cur1 = p?.currency1 ?? 'USD';

    _unit2Ctrl = TextEditingController(text: p?.unit2 ?? '');
    _price2Ctrl = TextEditingController(text: p?.shopPrice2.toString() ?? '0');
    _minPrice2Ctrl = TextEditingController(text: p?.minPrice2.toString() ?? '0');
    _costPrice2Ctrl = TextEditingController(text: p?.costPrice2.toString() ?? '0');
    _cur2 = p?.currency2 ?? 'USD';

    _unit3Ctrl = TextEditingController(text: p?.unit3 ?? '');
    _price3Ctrl = TextEditingController(text: p?.shopPrice3.toString() ?? '0');
    _minPrice3Ctrl = TextEditingController(text: p?.minPrice3.toString() ?? '0');
    _costPrice3Ctrl = TextEditingController(text: p?.costPrice3.toString() ?? '0');
    _cur3 = p?.currency3 ?? 'USD';

    _isActive = p?.isActive ?? true;

    if (p != null) {
      if (p.defaultUnit == p.unit2 && p.unit2.isNotEmpty) _defaultUnitIndex = 2;
      else if (p.defaultUnit == p.unit3 && p.unit3.isNotEmpty) _defaultUnitIndex = 3;
      else _defaultUnitIndex = 1;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    String defaultU = _unit1Ctrl.text.trim();
    if (_defaultUnitIndex == 2 && _unit2Ctrl.text.trim().isNotEmpty) defaultU = _unit2Ctrl.text.trim();
    if (_defaultUnitIndex == 3 && _unit3Ctrl.text.trim().isNotEmpty) defaultU = _unit3Ctrl.text.trim();

    final newProduct = ProductModel(
      id: widget.productToEdit?.id ?? '', itemCode: _codeCtrl.text.trim(), itemName: _nameCtrl.text.trim(),
      groupCode: widget.productToEdit?.groupCode ?? '', currencyCode: 'SYP', defaultUnit: defaultU, isActive: _isActive,
      tabName: _tabCtrl.text.trim(), columnIndex: int.tryParse(_colCtrl.text) ?? 0, rowIndex: widget.productToEdit?.rowIndex ?? widget.initialRow,

      unit1: _unit1Ctrl.text.trim(), barcode1: widget.productToEdit?.barcode1 ?? '', shopPrice1: double.tryParse(_price1Ctrl.text) ?? 0, consumerPrice1: 0, minPrice1: double.tryParse(_minPrice1Ctrl.text) ?? 0, costPrice1: double.tryParse(_costPrice1Ctrl.text) ?? 0, currency1: _cur1,
      unit2: _unit2Ctrl.text.trim(), barcode2: widget.productToEdit?.barcode2 ?? '', shopPrice2: double.tryParse(_price2Ctrl.text) ?? 0, consumerPrice2: 0, minPrice2: double.tryParse(_minPrice2Ctrl.text) ?? 0, costPrice2: double.tryParse(_costPrice2Ctrl.text) ?? 0, currency2: _cur2,
      unit3: _unit3Ctrl.text.trim(), barcode3: widget.productToEdit?.barcode3 ?? '', shopPrice3: double.tryParse(_price3Ctrl.text) ?? 0, consumerPrice3: 0, minPrice3: double.tryParse(_minPrice3Ctrl.text) ?? 0, costPrice3: double.tryParse(_costPrice3Ctrl.text) ?? 0, currency3: _cur3,
      isSynced: false,
    );

    context.read<ProductsRepository>().saveProductAdmin(newProduct, isNew: widget.productToEdit == null);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح'), backgroundColor: Colors.green));
    context.pop();
  }

  void _confirmDelete() async {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => const Center(child: CircularProgressIndicator()));
    final errorMessage = await context.read<ProductsManagementCubit>().checkProductUsage(widget.productToEdit!.id);
    if (mounted) Navigator.pop(context);

    if (errorMessage != null) {
      if (mounted) showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('ممنوع الحذف', style: TextStyle(color: Colors.red)), content: Text(errorMessage, style: const TextStyle(fontWeight: FontWeight.bold)), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً'))]));
    } else {
      if (mounted) {
        showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.red)),
          content: const Text('المادة غير مستخدمة في أي فاتورة. هل أنت متأكد من حذفها نهائياً؟'),
          actions:[
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<ProductsManagementCubit>().deleteProduct(widget.productToEdit!.id);
                context.pop();
              },
              child: const Text('حذف نهائي', style: TextStyle(color: Colors.white)),
            )
          ],
        ));
      }
    }
  }

  Widget _buildUnitRow(String title, int index, TextEditingController u, TextEditingController p, TextEditingController m, TextEditingController c, String currentCur, Function(String?) onCurChanged) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 16)),
                Row(
                  children:[
                    const Text('الوحدة الافتراضية:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Radio<int>(value: index, groupValue: _defaultUnitIndex, activeColor: Colors.teal, onChanged: (val) => setState(() => _defaultUnitIndex = val!)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children:[
                Expanded(flex: 3, child: TextFormField(controller: u, decoration: const InputDecoration(labelText: 'اسم الوحدة', isDense: true, border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: currentCur,
                    decoration: const InputDecoration(labelText: 'العملة', border: OutlineInputBorder(), isDense: true),
                    items: const [DropdownMenuItem(value: 'USD', child: Text('دولار \$')), DropdownMenuItem(value: 'SYP', child: Text('ليرة ل.س'))],
                    onChanged: onCurChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children:[
                Expanded(child: TextFormField(controller: c, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'التكلفة', isDense: true, border: OutlineInputBorder(), fillColor: Color(0xFFFFF3E0), filled: true))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: p, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'البيع', isDense: true, border: OutlineInputBorder(), fillColor: Color(0xFFE3F2FD), filled: true))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: m, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الحد الأدنى', isDense: true, border: OutlineInputBorder(), fillColor: Color(0xFFFFEBEE), filled: true))),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productToEdit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'تعديل مادة' : 'إضافة مادة جديدة'), actions: isEdit ?[IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _confirmDelete)] : null),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children:[
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'اسم المادة', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? '*' : null),
              const SizedBox(height: 12),
              Row(children:[Expanded(flex: 2, child: TextFormField(controller: _codeCtrl, decoration: const InputDecoration(labelText: 'الباركود', border: OutlineInputBorder()))), const SizedBox(width: 8), Expanded(flex: 3, child: TextFormField(controller: _tabCtrl, decoration: const InputDecoration(labelText: 'التبويب', border: OutlineInputBorder()))), const SizedBox(width: 8), Expanded(flex: 2, child: TextFormField(controller: _colCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'العمود', border: OutlineInputBorder())))]),
              const SizedBox(height: 16),

              _buildUnitRow('الوحدة الأولى (الصغرى)', 1, _unit1Ctrl, _price1Ctrl, _minPrice1Ctrl, _costPrice1Ctrl, _cur1, (v) => setState(() => _cur1 = v!)),
              const SizedBox(height: 8),
              _buildUnitRow('الوحدة الثانية (الوسطى)', 2, _unit2Ctrl, _price2Ctrl, _minPrice2Ctrl, _costPrice2Ctrl, _cur2, (v) => setState(() => _cur2 = v!)),
              const SizedBox(height: 8),
              _buildUnitRow('الوحدة الثالثة (الكبرى)', 3, _unit3Ctrl, _price3Ctrl, _minPrice3Ctrl, _costPrice3Ctrl, _cur3, (v) => setState(() => _cur3 = v!)),

              const SizedBox(height: 16),
              SwitchListTile(title: const Text('المادة نشطة (تظهر في الفواتير)'), value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), backgroundColor: Colors.teal), child: const Text('حفظ واعتماد المادة', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }
}