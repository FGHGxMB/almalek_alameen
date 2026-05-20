// lib/ui/screens/main_layout/main_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- أضفنا هذه لإغلاق التطبيق
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/main_layout/main_cubit.dart';
import '../../../logic/main_layout/main_state.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';

import '../dashboard/dashboard_screen.dart';
import '../transactions/transactions_screen.dart';
import '../customers/customers_screen.dart';
import '../company_accounts/company_accounts_screen.dart';
import '../settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  DateTime? _lastPressedAt; // لتخزين وقت آخر ضغطة لزر الرجوع

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const Scaffold();

    final user = authState.user;
    final hasCompanyAccess = user.permissions.companyAccountsView;

    final List<Widget> screens = [
      const DashboardScreen(),
      const TransactionsScreen(),
      const CustomersScreen(),
      if (hasCompanyAccess) const CompanyAccountsScreen(),
      const SettingsScreen(),
    ];

    final List<NavigationDestination> navItems = [
      const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'الملخص'),
      const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'المعاملات'),
      const NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'الزبائن'),
      if (hasCompanyAccess) const NavigationDestination(icon: Icon(Icons.account_balance_outlined), selectedIcon: Icon(Icons.account_balance), label: 'الشركة'),
      const NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'الإعدادات'),
    ];

    return BlocProvider(
      create: (context) => MainCubit(),
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          int currentIndex = 0;
          if (state is MainInitial) currentIndex = state.currentIndex;
          if (currentIndex >= screens.length) currentIndex = screens.length - 1;

          // السحر هنا: استخدام PopScope للتحكم بزر الرجوع
          return PopScope(
            canPop: false, // نمنع الخروج المباشر
            onPopInvoked: (didPop) {
              if (didPop) return;

              final now = DateTime.now();
              // إذا لم يضغط من قبل، أو مرت أكثر من ثانيتين على الضغطة الأولى
              if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
                _lastPressedAt = now;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('اضغط مرة أخرى للخروج من التطبيق', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                // إذا ضغط مرتين خلال ثانيتين، نغلق التطبيق
                SystemNavigator.pop();
              }
            },
            child: Scaffold(
              body: IndexedStack(index: currentIndex, children: screens),
              bottomNavigationBar: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) => context.read<MainCubit>().changeTab(index),
                destinations: navItems,
              ),
            ),
          );
        },
      ),
    );
  }
}