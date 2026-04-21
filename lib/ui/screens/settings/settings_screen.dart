// lib/ui/screens/settings/settings_screen.dart

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

  void _showEditEmailDialog(BuildContext context, SettingsCubit cubit, String currentEmail) {
    final controller = TextEditingController(text: currentEmail);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل البريد الإلكتروني'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'البريد الجديد', border: OutlineInputBorder()),
        ),
        actions:[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              cubit.updateEmail(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showEditPasswordDialog(BuildContext context, SettingsCubit cubit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة', border: OutlineInputBorder()),
        ),
        actions:[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              cubit.updatePassword(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
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
            if (state is SettingsSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            } else if (state is SettingsError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            final cubit = context.read<SettingsCubit>();

            return ListView(
              padding: const EdgeInsets.all(16),
              children:[
                // معلومات الحساب
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  Text(user.accountName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  Text(user.rank, style: TextStyle(color: Colors.teal.shade700)),
                                ],
                              ),
                            ),
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

                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('تعديل البريد الإلكتروني'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showEditEmailDialog(context, cubit, user.email),
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('تغيير كلمة المرور'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showEditPasswordDialog(context, cubit),
                ),

                const Divider(height: 32),

                // زر لوحة الإدارة يظهر فقط للأدمن
                PermissionGuard(
                  permissionCheck: (perms) => perms.adminAccess,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      const Text('الإدارة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ListTile(
                        tileColor: Colors.teal.shade50,
                        leading: const Icon(Icons.admin_panel_settings, color: Colors.teal),
                        title: const Text('لوحة تحكم المدير', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal),
                        onTap: () {
                          // الانتقال لشاشة الأدمن
                          context.push(AppRoutes.admin);
                        },
                      ),
                      const Divider(height: 32),
                    ],
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () {
                    context.read<AuthCubit>().logout();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}