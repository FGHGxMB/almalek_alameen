// lib/ui/screens/transactions/invoice_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/transactions/invoice_form_cubit.dart';
import '../../../data/repositories/customers_repository.dart';
import '../../../data/repositories/products_repository.dart';
import '../../../data/repositories/transactions_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../widgets/product_selection_grid.dart';

class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _discountController = TextEditingController();
  CustomerModel? _selectedCustomer;

  @override
  void dispose() {
    _noteController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (context) => InvoiceFormCubit(
        context.read<CustomersRepository>(),
        context.read<ProductsRepository>(),
        context.read<TransactionsRepository>(),
        authState.user,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('إنشاء فاتورة مبيعات'), centerTitle: true),
        body: BlocConsumer<InvoiceFormCubit, InvoiceFormState>(
          listener: (context, state) {
            if (state is InvoiceFormSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الفاتورة بنجاح'), backgroundColor: Colors.green));
              context.pop();
            } else if (state is InvoiceFormError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state is InvoiceFormLoading || state is InvoiceFormInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is InvoiceFormReady) {
              final cubit = context.read<InvoiceFormCubit>();
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
                            Row(
                              children:[
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: 'طريقة الدفع', border: OutlineInputBorder()),
                                    value: state.paymentMethod,
                                    items: const[
                                      DropdownMenuItem(value: 'cash', child: Text('نقدي')),
                                      DropdownMenuItem(value: 'credit', child: Text('آجل')),
                                    ],
                                    onChanged: (val) => cubit.updatePaymentMethod(val!),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _discountController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'الحسم', border: OutlineInputBorder()),
                                    onChanged: (val) => cubit.updateDiscount(double.tryParse(val) ?? 0.0),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _noteController,
                              decoration: const InputDecoration(labelText: 'البيان', border: OutlineInputBorder()),
                            ),
                            const Divider(height: 32, thickness: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                const Text('الأقلام (المواد)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ElevatedButton.icon(
                                  onPressed: () => _openProductsGrid(context, cubit, state.products),
                                  icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                                  label: const Text('إضافة مواد', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (state.selectedItems.isEmpty)
                              const Padding(padding: EdgeInsets.all(32.0), child: Center(child: Text('لم يتم إضافة مواد بعد'))),
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
                    color: Colors.teal.shade50,
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Text('الصافي: ${state.total}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                cubit.submitInvoice(selectedCustomer: _selectedCustomer!, note: _noteController.text.trim());
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                            child: const Text('حفظ الفاتورة', style: TextStyle(color: Colors.white, fontSize: 16)),
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

  void _openProductsGrid(BuildContext context, InvoiceFormCubit cubit, List<ProductModel> products) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade100,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Column(
            children: [
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