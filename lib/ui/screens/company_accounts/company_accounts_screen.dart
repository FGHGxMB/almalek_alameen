// lib/ui/screens/company_accounts/company_accounts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/company_accounts/company_accounts_cubit.dart';
import '../../../logic/company_accounts/company_accounts_state.dart';
import '../../../data/repositories/company_accounts_repository.dart';
import '../../../data/models/company_account_model.dart';
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
      return Colors.teal; // لون افتراضي آمن
    }
  }

  String _colorToHex(Color color) {
    // نتأكد من أخذ كود اللون الأساسي بدون الـ Alpha لمنع الأخطاء
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  // الألوان الجاهزة (Themes) للاختيار
  final List<Color> _availableColors = const[
    Color(0xFF2196F3), // أزرق
    Color(0xFFE91E63), // وردي
    Color(0xFF4CAF50), // أخضر
    Color(0xFFFF9800), // برتقالي
    Color(0xFF9C27B0), // بنفسجي
    Color(0xFF009688), // تركواز
    Color(0xFF607D8B), // أزرق رمادي
    Color(0xFF795548), // بني
    Color(0xFFF44336), // أحمر
  ];

  void _showAccountFormDialog(BuildContext context, {CompanyAccountModel? accountToEdit, int nextOrderIndex = 0}) {
    final isEdit = accountToEdit != null;
    final nameController = TextEditingController(text: isEdit ? accountToEdit.accountName : '');
    final balanceController = TextEditingController(text: isEdit ? accountToEdit.balance.toString() : '0');
    final currencyController = TextEditingController(text: isEdit ? accountToEdit.currency : 'SYP');
    String selectedType = isEdit ? accountToEdit.accountType : 'supplier';
    Color selectedColor = isEdit ? _hexToColor(accountToEdit.themeColor) : _availableColors[0];

    final repo = context.read<CompanyAccountsRepository>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(isEdit ? 'تعديل الحساب' : 'إضافة حساب شركة'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الحساب', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 12),
                  if (!isEdit)
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'نوع الحساب', border: OutlineInputBorder(), isDense: true),
                      items: const[
                        DropdownMenuItem(value: 'supplier', child: Text('مُورِّد')),
                        DropdownMenuItem(value: 'customer', child: Text('زبون شركة')),
                      ],
                      onChanged: (val) => setState(() => selectedType = val!),
                    ),
                  if (!isEdit) const SizedBox(height: 12),
                  Row(
                    children:[
                      Expanded(flex: 2, child: TextField(controller: balanceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الرصيد', border: OutlineInputBorder(), isDense: true))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: currencyController, decoration: const InputDecoration(labelText: 'العملة', border: OutlineInputBorder(), isDense: true))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('لون الثيم (الحدود والنصوص):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _availableColors.map((color) {
                      return InkWell(
                        onTap: () => setState(() => selectedColor = color),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: 16,
                          child: selectedColor == color ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions:[
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: selectedColor),
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  final hexTheme = _colorToHex(selectedColor);

                  try {
                    if (isEdit) {
                      await repo.updateCompanyAccount(
                        id: accountToEdit.id, name: nameController.text.trim(),
                        balance: double.tryParse(balanceController.text) ?? 0,
                        currency: currencyController.text.trim(),
                        themeColor: hexTheme, bgColor: '#FFFFFF', // لم نعد نستخدمه من السيرفر
                      );
                    } else {
                      await repo.createCompanyAccount(
                        name: nameController.text.trim(), type: selectedType,
                        initialBalance: double.tryParse(balanceController.text) ?? 0,
                        currency: currencyController.text.trim(),
                        themeColor: hexTheme, bgColor: '#FFFFFF', newOrderIndex: nextOrderIndex,
                      );
                    }
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
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final hasEditPermission = authState.user.permissions.companyAccountsEdit;

    return PermissionGuard(
      permissionCheck: (perms) => perms.companyAccountsView,
      fallback: Scaffold(
        appBar: AppBar(title: const Text('حسابات الشركة'), centerTitle: true),
        body: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[Icon(Icons.lock_outline, size: 80, color: Colors.grey), SizedBox(height: 16), Text('لا تملك صلاحية لعرض حسابات الشركة', style: TextStyle(fontSize: 18, color: Colors.grey))])),
      ),
      child: BlocProvider(
        create: (context) => CompanyAccountsCubit(context.read<CompanyAccountsRepository>()),
        child: Scaffold(
          appBar: AppBar(title: const Text('حسابات الشركة'), centerTitle: true),
          body: BlocBuilder<CompanyAccountsCubit, CompanyAccountsState>(
            builder: (context, state) {
              if (state is CompanyAccountsLoading) return const Center(child: CircularProgressIndicator());
              if (state is CompanyAccountsError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              if (state is CompanyAccountsLoaded) {
                if (state.accounts.isEmpty) return const Center(child: Text('لا توجد حسابات مسجلة للشركة.'));

                return ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                  buildDefaultDragHandles: hasEditPermission,
                  itemCount: state.accounts.length,
                  onReorder: (oldIndex, newIndex) {
                    context.read<CompanyAccountsCubit>().reorder(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final account = state.accounts[index];

                    // السحر هنا: نأخذ لون الثيم، وننشئ منه لون الخلفية الشفاف برمجياً بنسبة 10%
                    final themeColor = _hexToColor(account.themeColor);
                    final dynamicBgColor = themeColor.withOpacity(0.1);

                    return Card(
                      key: ValueKey(account.id),
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: themeColor.withOpacity(0.4), width: 1.5),
                      ),
                      color: dynamicBgColor, // الخلفية الديناميكية المريحة للعين
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: themeColor,
                          child: Icon(account.accountType == 'supplier' ? Icons.store : Icons.apartment, color: Colors.white, size: 20),
                        ),
                        title: Text(account.accountName, style: TextStyle(fontWeight: FontWeight.bold, color: themeColor)),
                        subtitle: Text(account.accountType == 'supplier' ? 'مُورِّد' : 'زبون شركة', style: TextStyle(fontSize: 12, color: themeColor.withOpacity(0.7))),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children:[
                                Text('الرصيد', style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                                Text(
                                  '${NumberFormat.currency(symbol: '', decimalDigits: 1).format(account.balance)} ${account.currency}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: themeColor),
                                ),
                              ],
                            ),
                            if (hasEditPermission) ...[
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: themeColor),
                                onSelected: (val) {
                                  if (val == 'edit') _showAccountFormDialog(context, accountToEdit: account);
                                  if (val == 'delete') context.read<CompanyAccountsCubit>().deleteAccount(account.id);
                                },
                                itemBuilder: (context) =>[
                                  const PopupMenuItem(value: 'edit', child: Row(children:[Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('تعديل')])),
                                  const PopupMenuItem(value: 'delete', child: Row(children:[Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('حذف', style: TextStyle(color: Colors.red))])),
                                ],
                              )
                            ]
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
          floatingActionButton: PermissionGuard(
            permissionCheck: (perms) => perms.companyAccountsEdit,
            child: Builder(
                builder: (context) {
                  return FloatingActionButton(
                    backgroundColor: Colors.teal,
                    onPressed: () {
                      final cubit = context.read<CompanyAccountsCubit>();
                      int nextIndex = 0;
                      if (cubit.state is CompanyAccountsLoaded) {
                        nextIndex = (cubit.state as CompanyAccountsLoaded).accounts.length;
                      }
                      _showAccountFormDialog(context, nextOrderIndex: nextIndex);
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  );
                }
            ),
          ),
        ),
      ),
    );
  }
}