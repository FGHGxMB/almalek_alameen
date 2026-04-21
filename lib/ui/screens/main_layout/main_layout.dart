// lib/ui/screens/main_layout/main_layout.dart
import '../customers/customers_screen.dart';

import '../dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/main_layout/main_cubit.dart';
import '../../../logic/main_layout/main_state.dart';
import '../transactions/transactions_screen.dart';
import '../company_accounts/company_accounts_screen.dart';
import '../settings/settings_screen.dart';

// شاشات مؤقتة لحين برمجتها بالكامل
class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen(this.title, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Center(child: Text(title, style: const TextStyle(fontSize: 24)));
}

class MainLayout extends StatelessWidget {
  const MainLayout({Key? key}) : super(key: key);

  final List<Widget> _screens = const[
    DashboardScreen(), // <--- شاشة لوحة القيادة الحقيقية
    TransactionsScreen(), // <--- شاشة المعاملات الحقيقية
    CustomersScreen(), // <--- شاشة الزبائن الحقيقية
    CompanyAccountsScreen(), // <--- شاشة حسابات الشركة الحقيقية
    SettingsScreen(), // <--- شاشة الإعدادات الحقيقية
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainCubit(),
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          int currentIndex = 0;
          if (state is MainInitial) {
            currentIndex = state.currentIndex;
          }

          return Scaffold(
            body: IndexedStack(
              index: currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                context.read<MainCubit>().changeTab(index);
              },
              destinations: const[
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'الرئيسية'),
                NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'المعاملات'),
                NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'الزبائن'),
                NavigationDestination(icon: Icon(Icons.account_balance_outlined), selectedIcon: Icon(Icons.account_balance), label: 'الشركة'),
                NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'الإعدادات'),
              ],
            ),
          );
        },
      ),
    );
  }
}