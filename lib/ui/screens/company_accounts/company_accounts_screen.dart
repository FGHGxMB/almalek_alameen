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

  // دالة مساعدة لتحويل النص اللوني #FFFFFF إلى Color Object
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey; // لون افتراضي في حال كان الكود اللوني خاطئاً
    }
  }

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      permissionCheck: (perms) => perms.companyAccountsView,
      // الشاشة البديلة في حال عدم وجود الصلاحية
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
      // الشاشة الأساسية في حال وجود الصلاحية
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
                if (state.accounts.isEmpty) {
                  return const Center(child: Text('لا توجد حسابات مسجلة للشركة.'));
                }

                return ListView.builder(
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
                          children: [
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
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}