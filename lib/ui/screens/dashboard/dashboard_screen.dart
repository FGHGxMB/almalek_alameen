// lib/ui/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/dashboard/dashboard_cubit.dart';
import '../../../logic/dashboard/dashboard_state.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../data/repositories/dashboard_repository.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // جلب المستخدم الحالي من AuthCubit
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    final currentUser = authState.user;

    return BlocProvider(
      create: (context) => DashboardCubit(
        context.read<DashboardRepository>(),
        currentUser,
      )..fetchDashboardData(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('لوحة القيادة'),
            centerTitle: true,
            elevation: 0,
          ),
          body: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading || state is DashboardInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DashboardError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              } else if (state is DashboardLoaded) {
                final cubit = context.read<DashboardCubit>();

                return RefreshIndicator(
                  onRefresh: () async => cubit.fetchDashboardData(),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children:[
                      // قسم الفلاتر (التاريخ والمندوب)
                      _buildFilters(context, state, cubit, currentUser),
                      const SizedBox(height: 24),

                      // بطاقة الكاش الحي المباشر
                      _buildRealTimeCashCard(context, state.selectedDelegateId, state.selectedDate),
                      const SizedBox(height: 24),

                      // بطاقات الإحصائيات
                      const Text('إحصاءات اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildStatsGrid(state.stats),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      }),
    );
  }

  Widget _buildFilters(BuildContext context, DashboardLoaded state, DashboardCubit cubit, currentUser) {
    // تجهيز قائمة المندوبين (نفسه + من يراقبهم)
    // في تطبيق حقيقي يمكننا جلب أسمائهم، هنا نستخدم الـ ID مؤقتاً
    List<String> availableDelegates = [currentUser.id, ...currentUser.canMonitor];

    return Row(
      children:[
        // اختيار التاريخ
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (picked != null) cubit.changeDate(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children:[
                  const Icon(Icons.calendar_today, size: 20, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(DateFormat('yyyy-MM-dd').format(state.selectedDate)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // اختيار المندوب (يظهر فقط إذا كان يراقب أحداً)
        if (currentUser.canMonitor.isNotEmpty)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: state.selectedDelegateId,
                  isExpanded: true,
                  items: availableDelegates.map((id) {
                    final name = state.delegateNames[id] ?? id; // قراءة الاسم السحري
                    return DropdownMenuItem(
                      value: id,
                      child: Text(id == currentUser.id ? 'حسابي ($name)' : name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) cubit.changeDelegate(val);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  // الكاش الحي من خلال StreamBuilder بدون حاجة لتحديث الصفحة
  Widget _buildRealTimeCashCard(BuildContext context, String delegateId, DateTime date) {
    return StreamBuilder<double>(
      stream: context.read<DashboardRepository>().getDailyCashStream(delegateId, date),
      builder: (context, snapshot) {
        final cash = snapshot.data ?? 0.0;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.teal, Colors.tealAccent]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const[BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Column(
            children:[
              const Text('كاش الصندوق اليوم', style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                NumberFormat.currency(symbol: '', decimalDigits: 2).format(cash),
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _statCard('المبيعات الإجمالية', stats['totalSales'], Icons.point_of_sale, Colors.blue),
        _statCard('المرتجعات', stats['totalReturns'], Icons.assignment_return, Colors.red),
        _statCard('سندات القبض', stats['totalReceipts'], Icons.receipt_long, Colors.green),
        _statCard('فواتير نقدي/آجل', '${stats['cashInvoicesCount']} / ${stats['creditInvoicesCount']}', Icons.pie_chart, Colors.orange, isCurrency: false),
      ],
    );
  }

  Widget _statCard(String title, dynamic value, IconData icon, Color color, {bool isCurrency = true}) {
    String displayValue = value.toString();
    if (isCurrency && value is double) {
      displayValue = NumberFormat.currency(symbol: '', decimalDigits: 1).format(value);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(displayValue, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}