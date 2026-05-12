// lib/ui/widgets/product_selection_grid.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String _formatNum(double num) => NumberFormat('#,##0').format(num);
  String _rawNum(double num) => num == num.toInt() ? num.toInt().toString() : num.toString();

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
      String u = p.defaultUnit.isNotEmpty ? p.defaultUnit : (p.unit1.isNotEmpty ? p.unit1 : 'حبة');
      double price = p.shopPrice1 * widget.currencyRate;

      // مطابقة السعر للوحدة الافتراضية
      if (u == p.unit2) price = p.shopPrice2 * widget.currencyRate;
      if (u == p.unit3) price = p.shopPrice3 * widget.currencyRate;

      widget.onProductAdded(p, 1.0, u, price, false);
    }
    Navigator.pop(context);
  }

  void _showSingleAddDialog(ProductModel p) {
    double qty = 1.0;

    String u = p.defaultUnit.isNotEmpty ? p.defaultUnit : (p.unit1.isNotEmpty ? p.unit1 : 'حبة');

    double _calcPrice(double basePrice, String currency) {
      return currency == 'USD' ? basePrice * widget.currencyRate : basePrice;
    }

    double price = _calcPrice(p.shopPrice1, p.currency1);
    double minPrice = _calcPrice(p.minPrice1, p.currency1);

    if (u == p.unit2) { price = _calcPrice(p.shopPrice2, p.currency2); minPrice = _calcPrice(p.minPrice2, p.currency2); }
    if (u == p.unit3) { price = _calcPrice(p.shopPrice3, p.currency3); minPrice = _calcPrice(p.minPrice3, p.currency3); }

    final qtyCtrl = TextEditingController(text: _rawNum(qty));
    final priceCtrl = TextEditingController(text: _rawNum(price));

    String? qtyError;
    String? priceError;

    showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (context, setState) {
            bool isPriceLocked = (!widget.isReturn) && (price == minPrice && minPrice > 0);

            return AlertDialog(
              title: Text('إضافة ${p.itemName}', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    TextFormField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'الكمية',
                        border: const OutlineInputBorder(),
                        errorText: qtyError,
                        suffixIcon: IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { qtyCtrl.clear(); setState(() => qty = 0); }),
                      ),
                      onChanged: (v) {
                        setState(() {
                          qty = double.tryParse(v) ?? 0;
                          qtyError = qty <= 0 ? 'لا يمكن أن تكون صفراً أو سالبة' : null;
                        });
                      },
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
                            if (v == p.unit1) { price = _calcPrice(p.shopPrice1, p.currency1); minPrice = _calcPrice(p.minPrice1, p.currency1); }
                            if (v == p.unit2) { price = _calcPrice(p.shopPrice2, p.currency2); minPrice = _calcPrice(p.minPrice2, p.currency2); }
                            if (v == p.unit3) { price = _calcPrice(p.shopPrice3, p.currency3); minPrice = _calcPrice(p.minPrice3, p.currency3); }

                            priceCtrl.text = _rawNum(price);
                            isPriceLocked = (!widget.isReturn) && (price == minPrice && minPrice > 0);
                            priceError = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      readOnly: isPriceLocked,
                      decoration: InputDecoration(
                        labelText: isPriceLocked ? 'السعر (مقفل)' : 'السعر الإفرادي',
                        filled: isPriceLocked,
                        fillColor: isPriceLocked ? Colors.grey.shade200 : Colors.white,
                        border: const OutlineInputBorder(),
                        errorText: priceError,
                        suffixIcon: isPriceLocked ? null : IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { priceCtrl.clear(); setState(() => price = 0); }),
                      ),
                      onChanged: (v) {
                        setState(() {
                          price = double.tryParse(v) ?? 0;
                          if (price <= 0) {
                            priceError = 'لا يمكن أن يكون صفراً أو سالباً';
                          } else if (!widget.isReturn && minPrice > 0 && price < minPrice) {
                            priceError = 'لا يمكن النزول تحت الأدنى: ${_formatNum(minPrice)}';
                          } else {
                            priceError = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 6),
                    if (minPrice > 0) Text('السعر الأدنى للوحدة: ${_formatNum(minPrice)}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              actions:[
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      qtyError = qty <= 0 ? 'لا يمكن أن تكون صفراً أو سالبة' : null;
                      if (price <= 0) {
                        priceError = 'لا يمكن أن يكون صفراً أو سالباً';
                      } else if (!widget.isReturn && minPrice > 0 && price < minPrice) {
                        priceError = 'لا يمكن النزول تحت السعر الأدنى';
                      } else {
                        priceError = null;
                      }
                    });

                    if (qtyError == null && priceError == null) {
                      widget.onProductAdded(p, qty, u, price, false);
                      Navigator.pop(ctx);
                    }
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

  Widget _buildTabContent(List<ProductModel> tabProducts) {
    if (tabProducts.isEmpty) return const Center(child: Text('لا توجد مواد مطابقة.'));

    final Map<int, List<ProductModel>> columnsMap = {};
    int maxCol = 0;

    for (var p in tabProducts) {
      if (p.columnIndex > maxCol) maxCol = p.columnIndex;
      columnsMap.putIfAbsent(p.columnIndex, () =>[]);
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
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, border: Border.all(color: Colors.grey.shade300, width: 0.5)),
                  child: Text('العمود ${cIdx + 1}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ),
                ...colProducts.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final p = entry.value;
                  final isSelected = selectedIds.contains(p.id);
                  final bgColor = isSelected ? Colors.blueAccent.withOpacity(0.3) : (idx % 2 == 0 ? Colors.white : Colors.grey.shade100);

                  return InkWell(
                    onLongPress: () { setState(() { isSelectionMode = true; selectedIds.add(p.id); }); },
                    onTap: () {
                      if (isSelectionMode) _toggleSelection(p.id);
                      else _showSingleAddDialog(p);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
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
    final filteredProducts = widget.products.where((p) => p.itemName.toLowerCase().contains(searchQuery.toLowerCase())).toList();

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