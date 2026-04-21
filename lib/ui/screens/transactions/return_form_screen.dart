// lib/ui/screens/transactions/return_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/transactions/return_form_cubit.dart';
import '../../../data/repositories/customers_repository.dart';
import '../../../data/repositories/products_repository.dart';
import '../../../data/repositories/transactions_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../widgets/product_selection_grid.dart';

class ReturnFormScreen extends StatefulWidget {
  const ReturnFormScreen({Key? key}) : super(key: key);

  @override
  State<ReturnFormScreen> createState() => _ReturnFormScreenState();
}

class _ReturnFormScreenState extends State<ReturnFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _invoiceRefController = TextEditingController();
  CustomerModel? _selectedCustomer;

  @override
  void dispose() {
    _noteController.dispose();
    _invoiceRefController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (context) => ReturnFormCubit(
        context.read<CustomersRepository>(),
        context.read<ProductsRepository>(),
        context.read<TransactionsRepository>(),
        authState.user,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء مرتجع مبيعات'),
          centerTitle: true,
          backgroundColor: Colors.red.shade600, // لون مميز للمرتجع
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<ReturnFormCubit, ReturnFormState>(
          listener: (context, state) {
            if (state is ReturnFormSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ المرتجع بنجاح'), backgroundColor: Colors.green));
              context.pop();
            } else if (state is ReturnFormError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state is ReturnFormLoading || state is ReturnFormInitial) {
              return const Center(child: CircularProgressIndicator(color: Colors.red));
            } else if (state is ReturnFormReady) {
              final cubit = context.read<ReturnFormCubit>();
              return Column(
                children:[
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children:[
                            DropdownButtonFormField<CustomerModel>(
                              decoration: const InputDecoration(labelText: 'الزبون', border: OutlineInputBorder()),
                              value: _selectedCustomer,
                              items: state.customers.map((c) => DropdownMenuItem(value: c, child: Text(c.customerName))).toList(),
                              onChanged: (val) => setState(() => _selectedCustomer = val),
                              validator: (val) => val == null ? 'الرجاء اختيار الزبون' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'طريقة الدفع (لرد المبلغ أو خصم الرصيد)', border: OutlineInputBorder()),
                              value: state.paymentMethod,
                              items: const[
                                DropdownMenuItem(value: 'cash', child: Text('نقدي')),
                                DropdownMenuItem(value: 'credit', child: Text('آجل')),
                              ],
                              onChanged: (val) => cubit.updatePaymentMethod(val!),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children:[
                                Expanded(
                                  child: TextFormField(
                                    controller: _invoiceRefController,
                                    decoration: const InputDecoration(labelText: 'رقم الفاتورة الأصلية (اختياري)', border: OutlineInputBorder()),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _noteController,
                                    decoration: const InputDecoration(labelText: 'البيان', border: OutlineInputBorder()),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32, thickness: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                const Text('المواد المرتجعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ElevatedButton.icon(
                                  onPressed: () => _openProductsGrid(context, cubit, state.products),
                                  icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                                  label: const Text('إضافة مواد', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (state.selectedItems.isEmpty)
                              const Padding(padding: EdgeInsets.all(32.0), child: Center(child: Text('لم يتم إضافة مواد للمرتجع بعد'))),
                            ...state.selectedItems.map((item) {
                              final productName = state.products.firstWhere((p) => p.id == item.productId).itemName;
                              return Card(
                                child: ListTile(
                                  title: Text('$productName (${item.unit})'),
                                  subtitle: Text('${item.quantity} × ${item.price} = ${item.quantity * item.price}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => cubit.removeItem(item.productId, item.unit),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red.shade50,
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Text('إجمالي المرتجع: ${state.total}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                cubit.submitReturn(
                                  selectedCustomer: _selectedCustomer!,
                                  note: _noteController.text.trim(),
                                  invoiceRef: _invoiceRefController.text.trim(),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                            child: const Text('حفظ المرتجع', style: TextStyle(color: Colors.white, fontSize: 16)),
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

  void _openProductsGrid(BuildContext context, ReturnFormCubit cubit, List<ProductModel> products) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade100,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Column(
            children:[
              AppBar(title: const Text('اختر المواد'), automaticallyImplyLeading: false, actions:[CloseButton(onPressed: () => Navigator.pop(context))]),
              Expanded(
                child: ProductSelectionGrid(
                  products: products,
                  onProductAdded: (p, q, u, pr) => cubit.addItem(p, q, u, pr),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}