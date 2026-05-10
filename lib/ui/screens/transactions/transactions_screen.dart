// lib/ui/screens/transactions/transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/unified_transaction.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/transactions/transactions_cubit.dart';
import '../../../logic/transactions/transactions_state.dart';
import '../../../data/repositories/transactions_repository.dart';
import '../../widgets/transaction_card.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/common/permission_guard.dart';
import '../../widgets/transaction_filters_panel.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final currentUser = authState.user;

    return BlocProvider(
      create: (context) => TransactionsCubit(context.read<TransactionsRepository>(), currentUser),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<TransactionsCubit, TransactionsState>(
              builder: (context, state) {
                final cubit = context.read<TransactionsCubit>();
                if (cubit.isSelectionMode) return Text('${cubit.selectedIds.length} محدد');
                return const Text('سجل المعاملات');
              }
          ),
          actions:[
            BlocBuilder<TransactionsCubit, TransactionsState>(
                builder: (context, state) {
                  final cubit = context.read<TransactionsCubit>();
                  return Row(
                    children:[
                      if (cubit.isSelectionMode)
                        IconButton(icon: const Icon(Icons.select_all), onPressed: () { if (state is TransactionsLoaded) cubit.selectAll(state.transactions); }),
                      if (!cubit.isSelectionMode)
                        IconButton(
                          icon: Icon(Icons.filter_alt, color: cubit.hasActiveFilters ? Colors.orangeAccent : Colors.white),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => TransactionFiltersPanel(
                                currentFilters: cubit.filters,
                                usersMap: cubit.usersMap,
                                onApply: (newFilters) => cubit.updateFilters(newFilters),
                                onReset: () => cubit.resetFilters(),
                              ),
                            );
                          },
                        ),
                      PermissionGuard(
                        permissionCheck: (p) => p.exportData,
                        child: IconButton(icon: const Icon(Icons.file_download), onPressed: () => cubit.exportDataToExcel()),
                      ),
                    ],
                  );
                }
            )
          ],
        ),
        body: BlocConsumer<TransactionsCubit, TransactionsState>(
          listener: (context, state) {
            if (state is TransactionsError) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          },
          builder: (context, state) {
            if (state is TransactionsLoading) return const Center(child: CircularProgressIndicator());
            if (state is TransactionsLoaded) {
              final cubit = context.read<TransactionsCubit>();
              return Column(
                children:[
                  // شريط سعر الدولار
                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 6), color: Colors.grey.shade200,
                    child: Text('سعر الدولار اليوم: ${cubit.currencyRate}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => cubit.refreshDelegates(),
                      child: state.transactions.isEmpty
                          ? ListView(children: const[SizedBox(height: 300, child: Center(child: Text('لا توجد معاملات مسجلة.')))])
                          : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.transactions.length,
                        itemBuilder: (context, index) {
                          final t = state.transactions[index];
                          return TransactionCard(
                            transaction: t,
                            isSelected: cubit.selectedIds.contains(t.id),
                            onLongPress: () => cubit.toggleSelectionMode(t.id),
                            onTap: () {
                              if (cubit.isSelectionMode) {
                                cubit.toggleSelection(t.id);
                              } else {
                                if (t.type == TransactionType.invoice) {
                                  context.push(AppRoutes.invoiceForm, extra: t.originalDoc);
                                } else if (t.type == TransactionType.returnDoc) {
                                  context.push(AppRoutes.returnForm, extra: t.originalDoc);
                                } else if (t.type == TransactionType.receipt) {
                                  context.push(AppRoutes.receiptForm, extra: t.originalDoc); // تم إضافة فتح السند!
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
            builder: (context) {
              final canCreateInvoice = currentUser.permissions.invoiceCreate || currentUser.permissions.invoiceCreateMonitored;
              final canCreateReturn = currentUser.permissions.returnCreate || currentUser.permissions.returnCreateMonitored;
              final canCreateReceipt = currentUser.permissions.receiptCreate || currentUser.permissions.receiptCreateMonitored;

              if (!canCreateInvoice && !canCreateReturn && !canCreateReceipt) return const SizedBox.shrink();

              return FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                    builder: (_) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:[
                          const Padding(padding: EdgeInsets.all(16.0), child: Text('اختر نوع المعاملة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                          if (canCreateInvoice) ListTile(leading: const Icon(Icons.point_of_sale, color: Colors.blue), title: const Text('فاتورة مبيعات'), onTap: () { Navigator.pop(context); context.push(AppRoutes.invoiceForm); }),
                          if (canCreateReturn) ListTile(leading: const Icon(Icons.assignment_return, color: Colors.red), title: const Text('مرتجع مبيعات'), onTap: () { Navigator.pop(context); context.push(AppRoutes.returnForm); }),
                          if (canCreateReceipt) ListTile(leading: const Icon(Icons.receipt_long, color: Colors.green), title: const Text('سند قبض'), onTap: () { Navigator.pop(context); context.push(AppRoutes.receiptForm); }),
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