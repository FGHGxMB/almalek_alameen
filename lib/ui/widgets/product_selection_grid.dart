// lib/ui/widgets/product_selection_grid.dart

import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class ProductSelectionGrid extends StatefulWidget {
  final List<ProductModel> products;
  final double currencyRate;
  final bool isReturn;
  final Function(ProductModel, double, String, double, bool) onProductAdded;

  const ProductSelectionGrid({
    Key? key, required this.products, required this.currencyRate, required this.isReturn, required this.onProductAdded
  }) : super(key: key);

  @override
  State<ProductSelectionGrid> createState() => _ProductSelectionGridState();
}

class _ProductSelectionGridState extends State<ProductSelectionGrid> {
  bool isSelectionMode = false;
  Set<String> selectedIds = {};
  String searchQuery = '';

  void _toggleSelection(String id) {
    setState(() {
      if (selectedIds.contains(id)) selectedIds.remove(id);
      else selectedIds.add(id);
      if (selectedIds.isEmpty) isSelectionMode = false;
    });
  }

  void _addSelectedItemsAndExit() {
    for (var id in selectedIds) {
      final p = widget.products.firstWhere((prod) => prod.id == id);
      String u = p.unit1.isNotEmpty ? p.unit1 : (p.defaultUnit.isNotEmpty ? p.defaultUnit : 'حبة');
      double price = p.shopPrice1 * widget.currencyRate;
      widget.onProductAdded(p, 1.0, u, price, false); // الإضافة الفورية كأقلام مستقلة
    }
    Navigator.pop(context);
  }

  void _showSingleAddDialog(ProductModel p) {
    double qty = 1.0;
    String u = p.unit1.isNotEmpty ? p.unit1 : (p.defaultUnit.isNotEmpty ? p.defaultUnit : 'حبة');
    double price = p.shopPrice1 * widget.currencyRate;

    // جلب السعر الأدنى الحقيقي المضروب بالدولار
    double minPrice = p.minPrice1 * widget.currencyRate;

    showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (context, setState) {
            // يُقفل السعر فقط إذا كان مساوياً للأدنى "ولم يكن مرتجعاً"
            bool isPriceLocked = (!widget.isReturn) && (price == minPrice && minPrice > 0);

            return AlertDialog(
              title: Text('إضافة ${p.itemName}', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  TextFormField(
                    initialValue: qty.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الكمية', border: OutlineInputBorder()),
                    onChanged: (v) => qty = double.tryParse(v) ?? 1.0,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: u,
                    decoration: const InputDecoration(labelText: 'الوحدة', border: OutlineInputBorder()),
                    items:[
                      if (p.unit1.isNotEmpty) DropdownMenuItem(value: p.unit1, child: Text(p.unit1)),
                      if (p.unit2.isNotEmpty) DropdownMenuItem(value: p.unit2, child: Text(p.unit2)),
                      if (p.unit3.isNotEmpty) DropdownMenuItem(value: p.unit3, child: Text(p.unit3)),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          u = v;
                          if (v == p.unit1) { price = p.shopPrice1 * widget.currencyRate; minPrice = p.minPrice1 * widget.currencyRate; }
                          if (v == p.unit2) { price = p.shopPrice2 * widget.currencyRate; minPrice = p.minPrice2 * widget.currencyRate; }
                          if (v == p.unit3) { price = p.shopPrice3 * widget.currencyRate; minPrice = p.minPrice3 * widget.currencyRate; }
                          isPriceLocked = (!widget.isReturn) && (price == minPrice && minPrice > 0);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: ValueKey(price),
                    initialValue: price.toString(),
                    keyboardType: TextInputType.number,
                    readOnly: isPriceLocked,
                    decoration: InputDecoration(
                      labelText: isPriceLocked ? 'السعر (مقفل على الحد الأدنى)' : 'السعر الإفرادي',
                      filled: isPriceLocked,
                      fillColor: isPriceLocked ? Colors.grey.shade200 : Colors.white,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => price = double.tryParse(v) ?? price,
                  ),
                ],
              ),
              actions:[
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () {
                    if (qty <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن أن تكون الكمية صفراً أو سالبة'), backgroundColor: Colors.red));
                      return;
                    }
                    if (price <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن أن يكون السعر صفراً أو سالباً'), backgroundColor: Colors.red));
                      return;
                    }
                    if (!widget.isReturn && minPrice > 0 && price < minPrice) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('السعر أقل من الأدنى: $minPrice'), backgroundColor: Colors.red));
                      return;
                    }
                    widget.onProductAdded(p, qty, u, price, false);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: widget.isReturn ? Colors.red.shade600 : Colors.blueAccent),
                  child: const Text('إضافة للفاتورة', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          });
        }
    );
  }

  // دالة بناء الجدول الاحترافي المتزامن (مستقرة 100%)
  Widget _buildTabContent(List<ProductModel> tabProducts) {
    if (tabProducts.isEmpty) return const Center(child: Text('لا توجد مواد مطابقة.'));

    final Map<int, List<ProductModel>> columnsMap = {};
    int maxCol = 0;

    // تجميع المواد حسب العمود وترتيبها حسب الصف
    for (var p in tabProducts) {
      if (p.columnIndex > maxCol) maxCol = p.columnIndex;
      columnsMap.putIfAbsent(p.columnIndex, () => []);
      columnsMap[p.columnIndex]!.add(p);
    }

    for (var col in columnsMap.values) {
      col.sort((a, b) => a.rowIndex.compareTo(b.rowIndex));
    }

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(maxCol + 1, (cIdx) {
          final colProducts = columnsMap[cIdx] ??[];
          return Expanded(
            child: Column(
              children:[
                // ترويسة العمود
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, border: Border.all(color: Colors.grey.shade300, width: 0.5)),
                  child: Text('العمود ${cIdx + 1}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ),
                // المواد
                ...colProducts.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final p = entry.value;
                  final isSelected = selectedIds.contains(p.id);
                  // ألوان متناوبة (أبيض ورمادي فاتح)
                  final bgColor = isSelected ? Colors.blueAccent.withOpacity(0.3) : (idx % 2 == 0 ? Colors.white : Colors.grey.shade100);

                  return InkWell(
                    onLongPress: () { setState(() { isSelectionMode = true; selectedIds.add(p.id); }); },
                    onTap: () {
                      if (isSelectionMode) _toggleSelection(p.id);
                      else _showSingleAddDialog(p);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60, // توحيد الارتفاع لضمان التزامن البصري
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: bgColor, border: Border.all(color: Colors.grey.shade300, width: 0.5)),
                      child: Text(
                        p.itemName,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? Colors.black : Colors.black87, fontSize: 13),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // تطبيق البحث على المواد
    final filteredProducts = widget.products.where((p) => p.itemName.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    // تصنيف المواد حسب التبويبات
    final Map<String, List<ProductModel>> tabsMap = {};
    for (var p in filteredProducts) {
      final tName = p.tabName.isEmpty ? 'عام' : p.tabName;
      tabsMap.putIfAbsent(tName, () => []);
      tabsMap[tName]!.add(p);
    }

    final tabNames = tabsMap.keys.toList();

    return DefaultTabController(
      length: tabNames.isEmpty ? 1 : tabNames.length,
      child: Column(
        children:[
          // شريط البحث (كما في صورتك)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث عن مادة...',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
          ),

          if (tabNames.isEmpty)
            const Expanded(child: Center(child: Text('لا توجد مواد مطابقة للبحث.')))
          else ...[
            TabBar(
              isScrollable: true,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blueAccent,
              tabs: tabNames.map((t) => Tab(text: t)).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: tabNames.map((tName) => _buildTabContent(tabsMap[tName]!)).toList(),
              ),
            ),
          ],

          // شريط التحديد المتعدد العائم أسفل الشاشة
          if (isSelectionMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.blueAccent.shade100, boxShadow: const[BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Text('${selectedIds.length} مادة محددة', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ElevatedButton.icon(
                      onPressed: _addSelectedItemsAndExit,
                      icon: const Icon(Icons.add_task, color: Colors.blueAccent),
                      label: const Text('إضافة للفاتورة', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}