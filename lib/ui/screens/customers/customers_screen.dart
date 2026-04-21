// lib/ui/screens/customers/customers_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/customers/customers_cubit.dart';
import '../../../logic/customers/customers_state.dart';
import '../../../data/repositories/customers_repository.dart';
import '../../widgets/common/permission_guard.dart';
import '../../../core/constants/app_routes.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (context) => CustomersCubit(context.read<CustomersRepository>(), authState.user),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('دليل الزبائن'),
          centerTitle: true,
          actions:[
            PermissionGuard(
              permissionCheck: (perms) => perms.exportData,
              child: IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: 'تصدير زبائن إلى Excel',
                onPressed: () {
                  context.read<CustomersCubit>().exportDataToExcel();
                },
              ),
            ),
          ],
        ),
        body: BlocBuilder<CustomersCubit, CustomersState>(
          builder: (context, state) {
            if (state is CustomersLoading) return const Center(child: CircularProgressIndicator());
            if (state is CustomersError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            if (state is CustomersLoaded) {
              if (state.customers.isEmpty) return const Center(child: Text('لا يوجد زبائن مسجلين.'));
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.customers.length,
                itemBuilder: (context, index) {
                  final c = state.customers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Icon(c.gender == 'male' ? Icons.person : Icons.person_3, color: Colors.teal),
                      ),
                      title: Text(c.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${c.region} | رمز: ${c.accountCode}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          const Text('الرصيد', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(c.balance.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: c.balance > 0 ? Colors.red : Colors.green)),
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
        // حماية الزر بحيث لا يظهر إلا لمن يملك صلاحية إضافة زبون
        floatingActionButton: PermissionGuard(
          permissionCheck: (perms) => perms.customerCreate,
          child: FloatingActionButton(
            onPressed: () => context.push(AppRoutes.customerForm),
            backgroundColor: Colors.teal,
            child: const Icon(Icons.person_add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}