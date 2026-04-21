// lib/ui/screens/transactions/transactions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/transactions/transactions_cubit.dart';
import '../../../logic/transactions/transactions_state.dart';
import '../../../data/repositories/transactions_repository.dart';
import '../../widgets/transaction_card.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/common/permission_guard.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    final currentUser = authState.user;

    return BlocProvider(
      create: (context) => TransactionsCubit(
        RepositoryProvider.of<TransactionsRepository>(context),
        currentUser,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل المعاملات'),
          centerTitle: true,
          elevation: 0,
          actions:[
            PermissionGuard(
              permissionCheck: (perms) => perms.exportData,
              child: IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: 'تصدير إلى Excel',
                onPressed: () {
                  context.read<TransactionsCubit>().exportDataToExcel();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الفلاتر قيد التطوير')),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, state) {
            if (state is TransactionsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionsError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is TransactionsLoaded) {
              if (state.transactions.isEmpty) {
                return const Center(child: Text('لا توجد معاملات مسجلة بعد.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = state.transactions[index];
                  return TransactionCard(transaction: transaction);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
            builder: (context) {
              final canCreateInvoice = currentUser.permissions.invoiceCreate;
              final canCreateReturn = currentUser.permissions.returnCreate;
              final canCreateReceipt = currentUser.permissions.receiptCreate;

              // إذا لم يكن لديه أي صلاحية إنشاء، نخفي الزر تماماً
              if (!canCreateInvoice && !canCreateReturn && !canCreateReceipt) {
                return const SizedBox.shrink();
              }

              return FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (_) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:[
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('اختر نوع المعاملة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          if (canCreateInvoice)
                            ListTile(
                              leading: const Icon(Icons.point_of_sale, color: Colors.blue),
                              title: const Text('فاتورة مبيعات'),
                              onTap: () {
                                Navigator.pop(context); // إغلاق القائمة
                                context.push(AppRoutes.invoiceForm);
                              },
                            ),
                          if (canCreateReturn)
                            ListTile(
                              leading: const Icon(Icons.assignment_return, color: Colors.red),
                              title: const Text('مرتجع مبيعات'),
                              onTap: () {
                                Navigator.pop(context);
                                context.push(AppRoutes.returnForm);
                              },
                            ),
                          if (canCreateReceipt)
                            ListTile(
                              leading: const Icon(Icons.receipt_long, color: Colors.green),
                              title: const Text('سند قبض'),
                              onTap: () {
                                Navigator.pop(context);
                                context.push(AppRoutes.receiptForm);
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
                backgroundColor: Colors.teal,
                child: const Icon(Icons.add, color: Colors.white),
              );
            }
        ),
      ),
    );
  }
}