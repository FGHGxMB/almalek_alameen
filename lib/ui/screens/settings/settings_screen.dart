import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/settings/settings_cubit.dart';
import '../../../logic/settings/settings_state.dart';
import '../../widgets/common/permission_guard.dart';
import '../../../core/constants/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showEditPasswordDialog(BuildContext context, SettingsCubit cubit) {
    final controller = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('تغيير كلمة المرور'),
      content: TextField(controller: controller, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة', border: OutlineInputBorder())),
      actions:[
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        ElevatedButton(onPressed: () { cubit.updatePassword(controller.text.trim()); Navigator.pop(ctx); }, child: const Text('حفظ')),
      ],
    ));
  }

  void _showEditCurrencyDialog(BuildContext context, SettingsCubit cubit, double currentRate, String userName) {
    final controller = TextEditingController(text: currentRate.toString());
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('تعديل سعر الدولار'),
      content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر الصرف الجديد', border: OutlineInputBorder())),
      actions:[
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        ElevatedButton(
            onPressed: () {
              final newRate = double.tryParse(controller.text) ?? currentRate;
              cubit.updateCurrencyRate(newRate, userName); // تمرير السعر واسم المستخدم
              Navigator.pop(ctx);
            },
            child: const Text('حفظ السعر')
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final user = authState.user;

    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
        body: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsSuccess) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            if (state is SettingsError) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          },
          buildWhen: (previous, current) => current is SettingsLoaded || current is SettingsLoading,
          builder: (context, state) {
            final cubit = context.read<SettingsCubit>();

            return ListView(
              padding: const EdgeInsets.all(16),
              children:[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Row(
                          children:[
                            const CircleAvatar(child: Icon(Icons.person), radius: 30),
                            const SizedBox(width: 16),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text(user.accountName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(user.rank, style: TextStyle(color: Colors.teal.shade700))])),
                          ],
                        ),
                        const Divider(height: 32),
                        const Text('البريد الإلكتروني الحالي:', style: TextStyle(color: Colors.grey)),
                        Text(user.email, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text('إعدادات الحساب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                if (state is SettingsLoading) const LinearProgressIndicator(),

                ListTile(leading: const Icon(Icons.lock), title: const Text('تغيير كلمة المرور'), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: () => _showEditPasswordDialog(context, cubit)),

                const Divider(height: 32),

                // قسم الإدارة (يظهر فقط للأدمن)
                PermissionGuard(
                  permissionCheck: (perms) => perms.adminAccess,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      const Text('الإدارة والنظام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                      const SizedBox(height: 8),

                      // 1. سعر الدولار الحي
                      if (state is SettingsLoaded)
                      // 1. سعر الدولار الحي وسجله (يظهر لمن لديه صلاحية updateCurrency)
                        PermissionGuard(
                          permissionCheck: (perms) => perms.updateCurrency,
                          child: Column(
                            children:[
                              ListTile(
                                tileColor: Colors.teal.shade50,
                                leading: const Icon(Icons.attach_money, color: Colors.teal),
                                title: Row(
                                  children:[
                                    const Text('سعر الدولار: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    if (state is SettingsLoaded)
                                      Text('${state.currencyRate}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18)),
                                    if (state is SettingsLoaded && !state.isConfigSynced) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.cloud_off, color: Colors.orange, size: 18),
                                    ]
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children:[
                                    IconButton(
                                      icon: const Icon(Icons.history, color: Colors.blueGrey),
                                      tooltip: 'سجل التغييرات',
                                      onPressed: () => context.push(AppRoutes.currencyHistory),
                                    ),
                                    const Icon(Icons.edit, size: 20, color: Colors.teal),
                                  ],
                                ),
                                onTap: () {
                                  if (state is SettingsLoaded) {
                                    _showEditCurrencyDialog(context, cubit, state.currencyRate, user.accountName); // تمرير اسم المستخدم
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),

                      // 2. المعلومات الأساسية
                      ListTile(
                        tileColor: Colors.teal.shade50,
                        leading: const Icon(Icons.info_outline, color: Colors.teal),
                        title: Row(
                          children:[
                            const Text('المعلومات الأساسية للمؤسسة'),
                            // عرض الغيمة البرتقالية إذا كانت الإعدادات قيد الرفع
                            if (state is SettingsLoaded && !state.isConfigSynced) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                            ]
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal),
                        onTap: () => context.push(AppRoutes.basicInfo),
                      ),
                      const SizedBox(height: 8),

                      // 3. إدارة المواد
                      ListTile(
                        tileColor: Colors.teal.shade50,
                        leading: const Icon(Icons.inventory_2_outlined, color: Colors.teal),
                        title: Row(
                          children:[
                            const Text('إدارة المواد والأسعار'),
                            if (state is SettingsLoaded && !state.isProductsSynced) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                            ]
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal),
                        onTap: () => context.push(AppRoutes.productsManagement),
                      ),
                      const SizedBox(height: 8),

                      // 4. لوحة المستخدمين (الأدمن)
                      ListTile(
                        tileColor: Colors.teal.shade50,
                        leading: const Icon(Icons.admin_panel_settings, color: Colors.teal),
                        title: const Text('إدارة الصلاحيات والمندوبين', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal),
                        onTap: () => context.push(AppRoutes.admin),
                      ),
                      const Divider(height: 32),
                    ],
                  ),
                ),

                ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), onTap: () => context.read<AuthCubit>().logout()),
              ],
            );
          },
        ),
      ),
    );
  }
}