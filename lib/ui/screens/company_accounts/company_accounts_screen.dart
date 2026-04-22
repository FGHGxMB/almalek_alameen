// lib/ui/screens/company_accounts/company_accounts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/company_accounts/company_accounts_cubit.dart';
import '../../../logic/company_accounts/company_accounts_state.dart';
import '../../../data/repositories/company_accounts_repository.dart';
import '../../widgets/common/permission_guard.dart';

class CompanyAccountsScreen extends StatelessWidget {
  const CompanyAccountsScreen({Key? key}) : super(key: key);

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  // نافذة إضافة حساب جديد
  void _showAddAccountDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    String selectedType = 'supplier';
    final repo = context.read<CompanyAccountsRepository>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('إضافة حساب شركة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم الحساب', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'نوع الحساب', border: OutlineInputBorder()),
                  items: const[
                    DropdownMenuItem(value: 'supplier', child: Text('مُورِّد')),
                    DropdownMenuItem(value: 'customer', child: Text('زبون شركة')),
                  ],
                  onChanged: (val) => setState(() => selectedType = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الرصيد الافتتاحي', border: OutlineInputBorder()),
                ),
              ],
            ),
            actions:[
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  try {
                    await repo.createCompanyAccount(
                      name: nameController.text.trim(),
                      type: selectedType,
                      initialBalance: double.tryParse(balanceController.text) ?? 0,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                  }
                },
                child: const Text('حفظ', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      permissionCheck: (perms) => perms.companyAccountsView,
      fallback: Scaffold(
        appBar: AppBar(title: const Text('حسابات الشركة'), centerTitle: true),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('لا تملك صلاحية لعرض حسابات الشركة', style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
      ),
      child: BlocProvider(
        create: (context) => CompanyAccountsCubit(context.read<CompanyAccountsRepository>()),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('حسابات الشركة'),
            centerTitle: true,
          ),
          body: BlocBuilder<CompanyAccountsCubit, CompanyAccountsState>(
            builder: (context, state) {
              if (state is CompanyAccountsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CompanyAccountsError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              } else if (state is CompanyAccountsLoaded) {
                // ميزة الـ Refresh
                return RefreshIndicator(
                  onRefresh: () async {
                    // الـ Stream يتحدث تلقائياً، ولكن هذا يعطي تجربة مستخدم أفضل
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: state.accounts.isEmpty
                      ? ListView(children: const[SizedBox(height: 300, child: Center(child: Text('لا توجد حسابات مسجلة للشركة.')))])
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.accounts.length,
                    itemBuilder: (context, index) {
                      final account = state.accounts[index];
                      final bgColor = _hexToColor(account.backgroundColor);
                      final themeColor = _hexToColor(account.themeColor);

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: themeColor, width: 2),
                        ),
                        color: bgColor,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  Text(
                                    account.accountName,
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeColor),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: themeColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      account.accountType == 'supplier' ? 'مُورِّد' : 'زبون شركة',
                                      style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text('الرصيد الحالي', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                NumberFormat.currency(symbol: '', decimalDigits: 2).format(account.balance),
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: themeColor),
                              ),
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
          // زر إضافة حساب جديد محمي بالصلاحية
          floatingActionButton: PermissionGuard(
            permissionCheck: (perms) => perms.companyAccountsEdit,
            child: FloatingActionButton(
              backgroundColor: Colors.teal,
              onPressed: () => _showAddAccountDialog(context),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}