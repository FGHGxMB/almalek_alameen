// lib/ui/screens/customers/customers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/customers/customers_cubit.dart';
import '../../../logic/customers/customers_state.dart';
import '../../../data/repositories/customers_repository.dart';
import '../../widgets/common/permission_guard.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/customer_filters_panel.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    try { return Color(int.parse(buffer.toString(), radix: 16)); } catch(e) { return Colors.orange; }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final currentUser = authState.user;

    return BlocProvider(
      create: (context) => CustomersCubit(context.read<CustomersRepository>(), currentUser),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<CustomersCubit, CustomersState>(
              builder: (context, state) {
                final cubit = context.read<CustomersCubit>();
                if (cubit.isSelectionMode) return Text('${cubit.selectedIds.length} محدد');
                return const Text('دليل الزبائن');
              }
          ),
          actions:[
            BlocBuilder<CustomersCubit, CustomersState>(
                builder: (context, state) {
                  final cubit = context.read<CustomersCubit>();
                  return Row(
                    children:[
                      if (cubit.isSelectionMode)
                        IconButton(
                          icon: const Icon(Icons.select_all),
                          onPressed: () { if (state is CustomersLoaded) cubit.selectAll(state.customers); },
                        ),
                      // زر الفلتر يظهر دائماً ويختفي في وضع التحديد
                      if (!cubit.isSelectionMode)
                        IconButton(
                          icon: Icon(Icons.filter_alt, color: cubit.hasActiveFilters ? Colors.orangeAccent : Colors.white),
                          onPressed: () {
                            final allAreas = state is CustomersLoaded ? state.customers.map((c) => c.region).toSet().toList() : <String>[];
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => CustomerFiltersPanel(
                                currentFilters: cubit.filters,
                                availableAreas: allAreas,
                                usersMap: cubit.usersMap, // نمرر الخريطة لعرض الأسماء
                                onApply: (newFilters) => cubit.updateFilters(newFilters),
                                onReset: () => cubit.resetFilters(),
                              ),
                            );
                          },
                        ),
                      // زر الإكسل يظهر دائماً لمن لديه صلاحية
                      PermissionGuard(
                        permissionCheck: (p) => p.exportData,
                        child: IconButton(
                          icon: const Icon(Icons.file_download),
                          tooltip: 'تصدير إلى Excel',
                          onPressed: () => cubit.exportDataToExcel(),
                        ),
                      ),
                    ],
                  );
                }
            )
          ],
        ),
        body: BlocConsumer<CustomersCubit, CustomersState>(
          listener: (context, state) {
            if (state is CustomersError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state is CustomersLoading) return const Center(child: CircularProgressIndicator());
            if (state is CustomersLoaded) {
              final cubit = context.read<CustomersCubit>();
              if (state.customers.isEmpty) return const Center(child: Text('لا يوجد زبائن مطابقين للبحث.'));

              return RefreshIndicator(
                onRefresh: () => cubit.refreshData(), // <--- ميزة السحب للتحديث هنا
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.customers.length,
                  itemBuilder: (context, index) {
                    final c = state.customers[index];
                    final isSelected = cubit.selectedIds.contains(c.id);
                    final isMine = c.delegateId == currentUser.id;

                    final canEdit = (isMine && currentUser.permissions.customerEdit) || (!isMine && currentUser.permissions.customerEditMonitored);
                    final canDelete = (isMine && currentUser.permissions.customerDelete) || (!isMine && currentUser.permissions.customerDeleteMonitored);

                    final ownerName = cubit.usersMap[c.delegateId]?.accountName ?? 'مجهول';
                    final ownerColor = _hexToColor(cubit.usersMap[c.delegateId]?.accountColor ?? '#FFA500');
                    final ownerSuffix = cubit.usersMap[c.delegateId]?.customerSuffix ?? '';

                    // إخفاء البادئة من واجهة العرض بأمان
                    String displayTitle = c.customerName;
                    if (ownerSuffix.isNotEmpty && displayTitle.startsWith(ownerSuffix)) {
                      displayTitle = displayTitle.replaceFirst(ownerSuffix, '').trim();
                    }

                    return Card(
                      color: isSelected ? Colors.teal.shade50 : Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onLongPress: () => cubit.toggleSelectionMode(c.id),
                        onTap: () {
                          if (cubit.isSelectionMode) cubit.toggleSelection(c.id);
                        },
                        leading: isSelected
                            ? const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.check, color: Colors.white))
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            CircleAvatar(radius: 16, backgroundColor: Colors.teal.shade100, child: Icon(c.gender == 'male' ? Icons.person : Icons.person_3, color: Colors.teal, size: 20)),
                            if (!isMine)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(color: ownerColor, borderRadius: BorderRadius.circular(4)),
                                child: Text(ownerName.length > 6 ? ownerName.substring(0,6) : ownerName, style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                          ],
                        ),
                        title: Text(displayTitle, style: const TextStyle(fontWeight: FontWeight.bold)), // استخدمنا الاسم الصافي
                        subtitle: Text('${c.gender == 'male' ? 'ذكر' : 'أنثى'} | رمز: ${c.accountCode}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:[
                            if (!c.isSynced)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                                child: Icon(Icons.cloud_off, color: Colors.orange, size: 20),
                              ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:[
                                const Text('الرصيد', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                Text(NumberFormat('#,##0.##').format(c.balance), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: c.balance > 0 ? Colors.red : Colors.green)),
                              ],
                            ),
                            if (canEdit || canDelete)
                              PopupMenuButton<String>(
                                onSelected: (val) {
                                  if (val == 'edit' && canEdit) {
                                    context.push(AppRoutes.customerForm, extra: {
                                      'customer': c,
                                      'targetDelegateId': c.delegateId,
                                      'ownerSuffix': ownerSuffix,
                                    });
                                  }
                                  if (val == 'delete' && canDelete) {
                                    showDialog(context: context, builder: (ctx) => AlertDialog(
                                        title: const Text('تأكيد الحذف'),
                                        content: const Text('هل أنت متأكد من حذف هذا الزبون نهائياً؟'),
                                        actions:[
                                          TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('إلغاء')),
                                          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: (){cubit.deleteCustomer(c.id); Navigator.pop(ctx);}, child: const Text('حذف', style: TextStyle(color: Colors.white))),
                                        ]
                                    ));
                                  }
                                },
                                itemBuilder: (ctx) =>[
                                  if(canEdit) const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                                  if(canDelete) const PopupMenuItem(value: 'delete', child: Text('حذف', style: TextStyle(color: Colors.red))),
                                ],
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
            builder: (context) {
              final hasPermission = currentUser.permissions.customerCreate || currentUser.permissions.customerCreateMonitored;
              if (!hasPermission) return const SizedBox.shrink();
              return FloatingActionButton(
                onPressed: () => context.push(AppRoutes.customerForm, extra: {'targetDelegateId': currentUser.id}),
                backgroundColor: Colors.teal,
                child: const Icon(Icons.person_add, color: Colors.white),
              );
            }
        ),
      ),
    );
  }
}