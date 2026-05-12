// lib/ui/screens/products_management/products_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/products_management/products_management_cubit.dart';
import '../../../data/repositories/products_repository.dart';
import '../../../data/models/product_model.dart';
import '../../../core/constants/app_routes.dart';

class ProductsManagementScreen extends StatefulWidget {
  const ProductsManagementScreen({Key? key}) : super(key: key);
  @override
  State<ProductsManagementScreen> createState() => _ProductsManagementScreenState();
}

class _ProductsManagementScreenState extends State<ProductsManagementScreen> {
  String? _currentTab;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductsManagementCubit(context.read<ProductsRepository>()),
      child: BlocBuilder<ProductsManagementCubit, ProductsManagementState>(
        builder: (context, state) {
          if (state is! PMLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

          final products = state.products;

          // تنظيم التبويبات والأعمدة
          final Map<String, Map<int, List<ProductModel>>> tabsMap = {};
          for (var p in products) {
            final tName = p.tabName.isEmpty ? 'عام' : p.tabName;
            tabsMap.putIfAbsent(tName, () => {});
            tabsMap[tName]!.putIfAbsent(p.columnIndex, () =>[]);
            tabsMap[tName]![p.columnIndex]!.add(p);
          }
          for (var t in tabsMap.values) {
            for (var c in t.values) c.sort((a, b) => a.rowIndex.compareTo(b.rowIndex));
          }

          final tabNames = tabsMap.keys.toList();
          if (tabNames.isNotEmpty && _currentTab == null) _currentTab = tabNames[0];
          if (!tabNames.contains(_currentTab) && tabNames.isNotEmpty) _currentTab = tabNames[0];

          return DefaultTabController(
            length: tabNames.isEmpty ? 1 : tabNames.length,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('إدارة المواد والأسعار'),
                bottom: tabNames.isEmpty ? null : TabBar(
                  isScrollable: true,
                  onTap: (index) => setState(() => _currentTab = tabNames[index]),
                  tabs: tabNames.map((tName) {
                    // السحر: جعل التبويب DragTarget ليتم إفلات المادة عليه ونقلها لتبويب آخر!
                    return DragTarget<ProductModel>(
                      onAccept: (product) {
                        if (product.tabName != tName) {
                          context.read<ProductsManagementCubit>().moveProduct(product.id, tName, 0, 999);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم نقل ${product.itemName} إلى $tName')));
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Tab(
                          child: Container(
                            color: candidateData.isNotEmpty ? Colors.orange.withOpacity(0.3) : Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(tName),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              body: tabNames.isEmpty
                  ? const Center(child: Text('لا توجد مواد مسجلة'))
                  : TabBarView(
                physics: const NeverScrollableScrollPhysics(), // منع السحب باليد لكي لا يتضارب مع سحب المواد
                children: tabNames.map((tName) {
                  final cols = tabsMap[tName]!;
                  int maxCol = cols.keys.isEmpty ? 0 : cols.keys.reduce((a, b) => a > b ? a : b);

                  return SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(maxCol + 2, (cIdx) { // +1 لعمود إضافي فارغ يمكن الإفلات فيه
                        final colProducts = cols[cIdx] ??[];
                        return Expanded(
                          child: DragTarget<ProductModel>(
                            onAccept: (product) {
                              // إذا سحبتها لنفس العمود لا نفعل شيء مؤقتاً (ممكن ترتيبها لاحقاً)،
                              // لكن إذا نقلتها لعمود جديد نحدث بياناتها
                              if (product.columnIndex != cIdx || product.tabName != tName) {
                                context.read<ProductsManagementCubit>().moveProduct(product.id, tName, cIdx, colProducts.length);
                              }
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                constraints: const BoxConstraints(minHeight: 500), // مساحة للإفلات
                                color: candidateData.isNotEmpty ? Colors.teal.shade50 : Colors.transparent,
                                child: Column(
                                  children:[
                                    Container(
                                      width: double.infinity, padding: const EdgeInsets.all(8),
                                      color: Colors.blueGrey.shade100,
                                      child: Text('العمود ${cIdx + 1}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    ...colProducts.asMap().entries.map((entry) {
                                      final p = entry.value;
                                      final bgColor = entry.key % 2 == 0 ? Colors.white : Colors.grey.shade100;

                                      return LongPressDraggable<ProductModel>(
                                        data: p,
                                        feedback: Material(
                                          elevation: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(12), color: Colors.orange.shade100,
                                            child: Text(p.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        childWhenDragging: Container(height: 50, color: Colors.grey.shade300),
                                        child: InkWell(
                                          onTap: () => context.push(AppRoutes.productForm, extra: p),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(color: bgColor, border: Border.all(color: Colors.grey.shade300, width: 0.5)),
                                            child: Row(
                                              children:[
                                                Expanded(child: Text(p.itemName, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                                if (!p.isSynced) const Icon(Icons.cloud_off, color: Colors.orange, size: 14),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  );
                }).toList(),
              ),
              floatingActionButton: Builder(
                  builder: (context) {
                    return FloatingActionButton(
                      backgroundColor: Colors.teal,
                      child: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        // تحديد التبويب الحالي والعمود الأخير لإنشاء المادة فيه
                        String tab = _currentTab ?? 'عام';
                        int col = 0;
                        int row = 0;
                        if (tabsMap.containsKey(tab)) {
                          final cols = tabsMap[tab]!;
                          if (cols.isNotEmpty) {
                            col = cols.keys.reduce((a, b) => a > b ? a : b);
                            row = cols[col]!.length;
                          }
                        }
                        // نمرر البيانات الأولية لشاشة إضافة المادة
                        context.push(AppRoutes.productForm, extra: {'tab': tab, 'col': col, 'row': row});
                      },
                    );
                  }
              ),
            ),
          );
        },
      ),
    );
  }
}