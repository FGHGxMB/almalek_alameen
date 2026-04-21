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

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({Key? key}) : super(key: key);

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
  final _prevBalanceController = TextEditingController(text: '0');

  String? _selectedRegion;
  String? _selectedGender;
  List<String> _areas =[];

  @override
  void initState() {
    super.initState();
    // جلب المناطق المحفوظة محلياً (Offline)
    _areas = context.read<ProductsRepository>().getLocalAreas();
  }

  @override
  void dispose() {
    _nameController.dispose(); _phone1Controller.dispose();
    _phone2Controller.dispose(); _emailController.dispose();
    _districtController.dispose(); _streetController.dispose();
    _notesController.dispose(); _prevBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (context) => CustomerFormCubit(context.read<CustomersRepository>(), authState.user),
      child: Scaffold(
        appBar: AppBar(title: const Text('إضافة زبون جديد'), centerTitle: true),
        body: BlocConsumer<CustomerFormCubit, CustomerFormState>(
          listener: (context, state) {
            if (state is CustomerFormSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء الزبون بنجاح'), backgroundColor: Colors.green));
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
                    const Text('الحقول الأساسية (إلزامية)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'اسم الزبون (المتجر/الشخص)', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'المنطقة', border: OutlineInputBorder()),
                      value: _selectedRegion,
                      items: _areas.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                      onChanged: (v) => setState(() => _selectedRegion = v),
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'الجنس', border: OutlineInputBorder()),
                      value: _selectedGender,
                      items: const[
                        DropdownMenuItem(value: 'male', child: Text('ذكر')),
                        DropdownMenuItem(value: 'female', child: Text('أنثى')),
                      ],
                      onChanged: (v) => setState(() => _selectedGender = v),
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _prevBalanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'الرصيد السابق (ديون قديمة إن وجدت)', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty || double.tryParse(v) == null ? 'قيمة غير صالحة' : null,
                    ),

                    const Divider(height: 32, thickness: 2),
                    const Text('معلومات إضافية (اختيارية)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),

                    Row(
                      children:[
                        Expanded(child: TextFormField(controller: _phone1Controller, decoration: const InputDecoration(labelText: 'هاتف 1', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)))),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(controller: _phone2Controller, decoration: const InputDecoration(labelText: 'هاتف 2', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(controller: _districtController, decoration: const InputDecoration(labelText: 'الحي', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: _streetController, decoration: const InputDecoration(labelText: 'الشارع', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder())),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is CustomerFormLoading ? null : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<CustomerFormCubit>().submitCustomer(
                              rawName: _nameController.text.trim(),
                              region: _selectedRegion!,
                              gender: _selectedGender!,
                              previousBalance: double.parse(_prevBalanceController.text.trim()),
                              phone1: _phone1Controller.text.trim(),
                              phone2: _phone2Controller.text.trim(),
                              email: _emailController.text.trim(),
                              district: _districtController.text.trim(),
                              street: _streetController.text.trim(),
                              notes: _notesController.text.trim(),
                              country: 'سوريا', // يجب جلبها من الإعدادات العامة لاحقاً
                              city: 'دمشق', // يجب جلبها من الإعدادات العامة لاحقاً
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.teal),
                        child: state is CustomerFormLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('حفظ واعتماد الزبون', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}