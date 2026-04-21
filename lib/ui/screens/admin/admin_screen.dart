// lib/ui/screens/admin/admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/admin/admin_cubit.dart';
import '../../../logic/admin/admin_state.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../core/constants/app_routes.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit(context.read<AdminRepository>()),
      child: Scaffold(
        appBar: AppBar(title: const Text('لوحة تحكم المدير'), centerTitle: true),
        body: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
            if (state is AdminError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            if (state is AdminLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user.isActive ? Colors.teal : Colors.red,
                        child: Icon(user.permissions.adminAccess ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
                      ),
                      title: Text(user.accountName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${user.rank} | ${user.email}'),
                      trailing: const Icon(Icons.edit),
                      onTap: () {
                        // تمرير المستخدم الحالي وكل المستخدمين (لصلاحية المراقبة)
                        context.push(AppRoutes.userEdit, extra: {'user': user, 'allUsers': state.users});
                      },
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
            builder: (context) {
              return FloatingActionButton(
                onPressed: () {
                  final state = context.read<AdminCubit>().state;
                  if (state is AdminLoaded) {
                    context.push(AppRoutes.userEdit, extra: {'user': null, 'allUsers': state.users});
                  }
                },
                backgroundColor: Colors.teal,
                child: const Icon(Icons.person_add, color: Colors.white),
              );
            }
        ),
      ),
    );
  }
}