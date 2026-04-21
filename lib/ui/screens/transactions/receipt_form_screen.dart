// lib/ui/screens/transactions/receipt_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../../logic/transactions/receipt_form_cubit.dart';
import '../../../../data/repositories/customers_repository.dart';
import '../../../../data/repositories/transactions_repository.dart';
import '../../../../data/models/customer_model.dart';

class ReceiptFormScreen extends StatefulWidget {
  const ReceiptFormScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptFormScreen> createState() => _ReceiptFormScreenState();
}

class _ReceiptFormScreenState extends State<ReceiptFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  CustomerModel? _selectedCustomer;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (context) => ReceiptFormCubit(
        context.read<CustomersRepository>(),
        context.read<TransactionsRepository>(),
        authState.user,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء سند قبض'),
          centerTitle: true,
        ),
        body: BlocConsumer<ReceiptFormCubit, ReceiptFormState>(
          listener: (context, state) {
            if (state is ReceiptFormSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إنشاء السند بنجاح'), backgroundColor: Colors.green),
              );
              context.pop(); // العودة للخلف
            } else if (state is ReceiptFormError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is ReceiptFormLoading || state is ReceiptFormInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ReceiptFormReady) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:[
                      // اختيار الزبون
                      DropdownButtonFormField<CustomerModel>(
                        decoration: const InputDecoration(
                          labelText: 'اختر الزبون',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        value: _selectedCustomer,
                        items: state.customers.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c.customerName),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCustomer = val),
                        validator: (val) => val == null ? 'الرجاء اختيار الزبون' : null,
                      ),
                      const SizedBox(height: 16),

                      // إدخال المبلغ
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'المبلغ المقبوض',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'الرجاء إدخال المبلغ';
                          if (double.tryParse(val) == null) return 'قيمة غير صالحة';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // البيان / ملاحظات
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'البيان (ملاحظات السند)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // زر الحفظ
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<ReceiptFormCubit>().submitReceipt(
                              selectedCustomer: _selectedCustomer!,
                              amount: double.parse(_amountController.text.trim()),
                              note: _noteController.text.trim(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text('حفظ السند', style: TextStyle(fontSize: 18, color: Colors.white)),
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