// lib/ui/widgets/product_selection_grid.dart

import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class ProductSelectionGrid extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel, double, String, double) onProductAdded;

  const ProductSelectionGrid({Key? key, required this.products, required this.onProductAdded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. تجميع المواد بناءً على tabName ثم columnIndex
    final Map<String, Map<int, List<ProductModel>>> tabs = {};
    for (var p in products) {
      final tName = p.tabName.isEmpty ? 'عام' : p.tabName;
      tabs.putIfAbsent(tName, () => {});
      tabs[tName]!.putIfAbsent(p.columnIndex, () =>[]);
      tabs[tName]![p.columnIndex]!.add(p);
    }

    // 2. ترتيب المواد داخل كل عمود بناءً على rowIndex
    for (var t in tabs.values) {
      for (var col in t.values) {
        col.sort((a, b) => a.rowIndex.compareTo(b.rowIndex));
      }
    }

    final tabNames = tabs.keys.toList();

    if (tabNames.isEmpty) return const Center(child: Text('لا توجد مواد مسجلة محلياً.'));

    return DefaultTabController(
      length: tabNames.length,
      child: Column(
        children:[
          TabBar(
            isScrollable: true,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            tabs: tabNames.map((t) => Tab(text: t)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: tabNames.map((tName) {
                final columnsMap = tabs[tName]!;
                final colIndices = columnsMap.keys.toList()..sort();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: colIndices.map((cIdx) {
                    final colProducts = columnsMap[cIdx]!;
                    return Expanded(
                      child: ListView.builder(
                        itemCount: colProducts.length,
                        itemBuilder: (context, idx) {
                          final p = colProducts[idx];
                          return InkWell(
                            onTap: () => _showAddDialog(context, p),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.teal.shade200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(p.itemName, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, ProductModel product) {
    double qty = 1.0;
    // تحديد الوحدة الافتراضية
    String selectedUnit = product.unit1.isNotEmpty ? product.unit1 : (product.defaultUnit.isNotEmpty ? product.defaultUnit : 'حبة');
    double price = product.shopPrice1;

    showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text('إضافة ${product.itemName}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      TextFormField(
                        initialValue: qty.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الكمية'),
                        onChanged: (v) => qty = double.tryParse(v) ?? 1.0,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedUnit,
                        items:[
                          if (product.unit1.isNotEmpty) DropdownMenuItem(value: product.unit1, child: Text(product.unit1)),
                          if (product.unit2.isNotEmpty) DropdownMenuItem(value: product.unit2, child: Text(product.unit2)),
                          if (product.unit3.isNotEmpty) DropdownMenuItem(value: product.unit3, child: Text(product.unit3)),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              selectedUnit = v;
                              // تغيير السعر تلقائياً بناءً على الوحدة
                              if (v == product.unit1) price = product.shopPrice1;
                              if (v == product.unit2) price = product.shopPrice2;
                              if (v == product.unit3) price = product.shopPrice3;
                            });
                          }
                        },
                        decoration: const InputDecoration(labelText: 'الوحدة'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey(price), // لإجبار التحديث عند تغير السعر من القائمة
                        initialValue: price.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'السعر الإفرادي'),
                        onChanged: (v) => price = double.tryParse(v) ?? price,
                      ),
                    ],
                  ),
                  actions:[
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                    ElevatedButton(
                      onPressed: () {
                        onProductAdded(product, qty, selectedUnit, price);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: const Text('إضافة للفاتورة', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              }
          );
        }
    );
  }
}