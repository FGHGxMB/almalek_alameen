// lib/ui/screens/customers/customer_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/customers/customer_form_cubit.dart';
import '../../../logic/customers/customers_state.dart';
import '../../../data/repositories/customers_repository.dart';
import '../../../data/repositories/products_repository.dart';
import '../../../data/models/customer_model.dart';

class CustomerFormScreen extends StatefulWidget {
  final CustomerModel? customerToEdit;
  final String? targetDelegateId;
  final String ownerSuffix;

  const CustomerFormScreen({
    Key? key, this.customerToEdit, this.targetDelegateId, this.ownerSuffix = ''
  }) : super(key: key);

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _districtController = TextEditingController();
  final _streetController = TextEditingController();
  final _notesController = TextEditingController();
  final _prevBalanceController = TextEditingController();

  String? _selectedRegion;
  String? _selectedGender;
  List<String> _areas =[];
  bool _isEdit = false;

  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    _areas = context.read<ProductsRepository>().getLocalAreas();
    _isEdit = widget.customerToEdit != null;

    if (_isEdit) {
      final c = widget.customerToEdit!;
      String cleanName = c.customerName;

      // إزالة البادئة من البداية إن وجدت
      if (widget.ownerSuffix.isNotEmpty && cleanName.startsWith(widget.ownerSuffix)) {
        cleanName = cleanName.replaceFirst(widget.ownerSuffix, '').trim();
      }
      // إزالة المنطقة من النهاية إن وجدت
      if (cleanName.endsWith(' - ${c.region}')) {
        cleanName = cleanName.substring(0, cleanName.length - (' - ${c.region}').length).trim();
      }

      _nameController.text = cleanName; // الاسم الصافي!

      _phone1Controller.text = c.phone1;
      _phone2Controller.text = c.phone2;
      _emailController.text = c.email;
      _districtController.text = c.district;
      _streetController.text = c.street;
      _notesController.text = c.notes;
      _prevBalanceController.text = c.previousBalance.toString();
      _selectedRegion = c.region;
      _selectedGender = c.gender;
    } else {
      _prevBalanceController.text = '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (context) => CustomerFormCubit(context.read<CustomersRepository>(), authState.user),
        child: PopScope(
          canPop: _canPop, // false بالوضع الطبيعي
          onPopInvoked: (didPop) {
            if (didPop) return;
            // إشعار لطيف للمندوب ليستخدم الزر الصحيح
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى استخدام سهم الرجوع في أعلى الشاشة.'), duration: Duration(seconds: 1)));
          },
          child: Scaffold(
        appBar: AppBar(
          // زر رجوع مخصص نتحكم به
            leading: IconButton(
              icon: const Icon(Icons.arrow_back), // السهم يتجه تلقائياً حسب اللغة
              onPressed: () {
                setState(() => _canPop = true); // نسمح بالخروج
                Future.delayed(const Duration(milliseconds: 50), () {
                  if (context.mounted) context.pop(); // نخرج بأمان
                });
              },
            ),
            title: Text(_isEdit ? 'تعديل الزبون' : 'إضافة زبون جديد'), centerTitle: true),
        body: BlocConsumer<CustomerFormCubit, CustomerFormState>(
          listener: (context, state) {
            if (state is CustomerFormSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح'), backgroundColor: Colors.green));
              setState(() => _canPop = true);
              context.pop();
            } else if (state is CustomerFormError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children:[
                    TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'اسم الزبون', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
                    const SizedBox(height: 12),
                    Autocomplete<String>(
                      initialValue: TextEditingValue(text: _selectedRegion ?? ''),
                      displayStringForOption: (String option) => option,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) return _areas;
                        return _areas.where((String area) {
                          return area.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        setState(() => _selectedRegion = selection);
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'المنطقة (ابحث أو اختر)',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                controller.clear();
                                setState(() => _selectedRegion = null);
                              },
                            ),
                          ),
                          onChanged: (val) {
                            setState(() => _selectedRegion = val);
                          },
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'الرجاء تحديد المنطقة';
                            // حماية: التأكد أن المنطقة التي أدخلها المندوب موجودة فعلاً في قائمة المناطق المسجلة
                            if (!_areas.contains(val.trim())) return 'هذه المنطقة غير مسجلة في النظام';
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(value: _selectedGender, items: const[DropdownMenuItem(value: 'male', child: Text('ذكر')), DropdownMenuItem(value: 'female', child: Text('أنثى'))], onChanged: (v) => setState(() => _selectedGender = v), decoration: const InputDecoration(labelText: 'الجنس', border: OutlineInputBorder()), validator: (v) => v == null ? 'مطلوب' : null),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _prevBalanceController,
                      keyboardType: TextInputType.number,
                      readOnly: _isEdit, // منع التعديل في وضع التحديث
                      decoration: InputDecoration(labelText: 'الرصيد السابق', border: const OutlineInputBorder(), filled: _isEdit),
                      validator: (v) => v!.isEmpty || double.tryParse(v) == null ? 'قيمة غير صالحة' : null,
                    ),
                    const Divider(height: 32),
                    Row(children:[Expanded(child: TextFormField(controller: _phone1Controller, decoration: const InputDecoration(labelText: 'هاتف 1', border: OutlineInputBorder()))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _phone2Controller, decoration: const InputDecoration(labelText: 'هاتف 2', border: OutlineInputBorder())))]),
                    const SizedBox(height: 12),
                    TextFormField(controller: _districtController, decoration: const InputDecoration(labelText: 'الحي', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: _streetController, decoration: const InputDecoration(labelText: 'الشارع', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder())),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, child: ElevatedButton(
                      onPressed: state is CustomerFormLoading ? null : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<CustomerFormCubit>().saveCustomer(
                            customerToEdit: widget.customerToEdit,
                            targetDelegateId: widget.targetDelegateId,
                            ownerSuffix: widget.ownerSuffix,
                            rawName: _nameController.text.trim(), region: _selectedRegion!, gender: _selectedGender!,
                            previousBalance: double.parse(_prevBalanceController.text.trim()), phone1: _phone1Controller.text.trim(),
                            phone2: _phone2Controller.text.trim(), email: _emailController.text.trim(), district: _districtController.text.trim(),
                            street: _streetController.text.trim(), notes: _notesController.text.trim(), country: 'سوريا', city: 'دمشق',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.teal),
                      child: state is CustomerFormLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('حفظ الزبون', style: TextStyle(fontSize: 18, color: Colors.white)),
                    )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
        ),
    );
  }
}