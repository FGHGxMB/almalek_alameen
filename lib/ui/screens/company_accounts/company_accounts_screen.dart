// lib/ui/screens/company_accounts/company_accounts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/company_accounts/company_accounts_cubit.dart';
import '../../../logic/company_accounts/company_accounts_state.dart';
import '../../../data/repositories/company_accounts_repository.dart';
import '../../../data/repositories/products_repository.dart';
import '../../../data/models/company_account_model.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/common/permission_guard.dart';
import '../../../logic/company_accounts/cost_materials_cubit.dart';
import '../../../data/models/cost_material_model.dart';

// =========================================================================
// الشاشة الرئيسية الحاضنة (تحوي التبويبين الرئيسيين)
// =========================================================================
class CompanyAccountsScreen extends StatelessWidget {
  const CompanyAccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. استخراج صلاحية التعديل للمستخدم الحالي
    final authState = context.read<AuthCubit>().state;
    final hasEditPermission = (authState is AuthAuthenticated)
        ? authState.user.permissions.companyAccountsEdit
        : false;

    return PermissionGuard(
      permissionCheck: (perms) => perms.companyAccountsView,
      fallback: Scaffold(
        appBar: AppBar(title: const Text('إدارة الشركة'), centerTitle: true),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('لا تملك صلاحية لعرض هذا القسم', style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('إدارة الشركة'),
            centerTitle: true,
            bottom: const TabBar(
              labelColor: Colors.teal,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.teal,
              indicatorWeight: 4,
              tabs:[
                Tab(text: 'الحسابات المالية', icon: Icon(Icons.account_balance_wallet)),
                Tab(text: 'تكلفة المواد', icon: Icon(Icons.inventory_2)),
              ],
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(), // منع التمرير لتجنب تعارض الإيماءات
            children:[
              const _FinancialAccountsView(), // التبويب الأول (الحسابات)
              _ProductsCostView(hasEditPermission: hasEditPermission),      // التبويب الثاني (تكلفة المواد)
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// التبويب الأول: الحسابات المالية (موردين، زبائن، أخرى)
// =========================================================================
class _FinancialAccountsView extends StatefulWidget {
  const _FinancialAccountsView({Key? key}) : super(key: key);
  @override
  State<_FinancialAccountsView> createState() => _FinancialAccountsViewState();
}

class _FinancialAccountsViewState extends State<_FinancialAccountsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Color> _availableColors = const[
    Color(0xFF2196F3), Color(0xFFE91E63), Color(0xFF4CAF50),
    Color(0xFFFF9800), Color(0xFF9C27B0), Color(0xFF009688),
    Color(0xFF607D8B), Color(0xFF795548), Color(0xFFF44336),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hexString) {
    try { return Color(int.parse(hexString.replaceFirst('#', 'ff'), radix: 16)); } catch (e) { return Colors.teal; }
  }
  String _colorToHex(Color color) => '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  void _showAccountFormDialog(BuildContext context, {CompanyAccountModel? accountToEdit, required int nextOrderIndex, required String defaultType}) {
    final isEdit = accountToEdit != null;
    final nameController = TextEditingController(text: isEdit ? accountToEdit.accountName : '');
    final balanceController = TextEditingController(text: isEdit ? accountToEdit.balance.toString() : '0');
    final currencyController = TextEditingController(text: isEdit ? accountToEdit.currency : '');
    Color selectedColor = isEdit ? _hexToColor(accountToEdit.themeColor) : _availableColors[0];
    final typeToSave = isEdit ? accountToEdit.accountType : defaultType;
    final repo = context.read<CompanyAccountsRepository>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(isEdit ? 'تعديل الحساب' : 'إضافة حساب جديد'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الحساب', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 12),
                  Row(
                    children:[
                      Expanded(flex: 2, child: TextFormField(controller: balanceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الرصيد', border: OutlineInputBorder(), isDense: true))),
                      const SizedBox(width: 8),
                      Expanded(child: TextFormField(controller: currencyController, decoration: const InputDecoration(labelText: 'العملة', border: OutlineInputBorder(), isDense: true))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('لون البطاقة:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _availableColors.map((color) {
                      return InkWell(
                        onTap: () => setState(() => selectedColor = color),
                        child: CircleAvatar(backgroundColor: color, radius: 16, child: selectedColor == color ? const Icon(Icons.check, color: Colors.white, size: 20) : null),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions:[
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: selectedColor),
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  final hexTheme = _colorToHex(selectedColor);
                  try {
                    if (isEdit) {
                      await repo.updateCompanyAccount(id: accountToEdit.id, name: nameController.text.trim(), balance: double.tryParse(balanceController.text) ?? 0, currency: currencyController.text.trim(), themeColor: hexTheme, bgColor: '#FFFFFF');
                    } else {
                      await repo.createCompanyAccount(name: nameController.text.trim(), type: typeToSave, initialBalance: double.tryParse(balanceController.text) ?? 0, currency: currencyController.text.trim(), themeColor: hexTheme, bgColor: '#FFFFFF', newOrderIndex: nextOrderIndex);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) { ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('خطأ: $e'))); }
                },
                child: const Text('حفظ', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildTabContent(BuildContext context, CompanyAccountsLoaded state, String typeFilter, bool hasEditPermission) {
    final tabAccounts = state.accounts.where((a) => a.accountType == typeFilter).toList();
    if (tabAccounts.isEmpty) return const Center(child: Text('لا توجد حسابات مسجلة في هذا القسم.'));

    final Map<String, List<CompanyAccountModel>> currencyGroups = {};
    for (var acc in tabAccounts) {
      currencyGroups.putIfAbsent(acc.currency, () => []);
      currencyGroups[acc.currency]!.add(acc);
    }

    // السحر هنا: استخراج العملات وترتيبها أبجدياً (مثلاً: SYP ثم USD)
    final sortedCurrencies = currencyGroups.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: sortedCurrencies.length, // نستخدم القائمة المرتبة
        itemBuilder: (context, index) {
          final currency = sortedCurrencies[index]; // نأخذ العملة بالترتيب الأبجدي
          final accountsInCurrency = currencyGroups[currency]!;
          final double totalForCurrency = accountsInCurrency.fold(0, (sum, acc) => sum + acc.balance);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              ReorderableListView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), buildDefaultDragHandles: hasEditPermission, itemCount: accountsInCurrency.length,
                onReorder: (oldIndex, newIndex) => context.read<CompanyAccountsCubit>().reorder(oldIndex, newIndex, accountsInCurrency),
                itemBuilder: (context, accIndex) {
                  final account = accountsInCurrency[accIndex];
                  final themeColor = _hexToColor(account.themeColor);
                  final dynamicBgColor = themeColor.withOpacity(0.08);

                  return Card(
                    key: ValueKey(account.id), elevation: 0, margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: themeColor.withOpacity(0.4), width: 1.5)), color: dynamicBgColor,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(backgroundColor: themeColor, child: Icon(Icons.account_balance_wallet, color: Colors.white, size: 20)),
                      title: Text(account.accountName, style: TextStyle(fontWeight: FontWeight.bold, color: themeColor, fontSize: 15)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children:[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
                            children:[
                              Text('الرصيد', style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                              Text('${NumberFormat.currency(symbol: '', decimalDigits: 1).format(account.balance)} ${account.currency}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: themeColor)),
                            ],
                          ),
                          if (hasEditPermission) ...[
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: themeColor),
                              onSelected: (val) {
                                if (val == 'edit') _showAccountFormDialog(context, accountToEdit: account, nextOrderIndex: 0, defaultType: '');
                                if (val == 'delete') context.read<CompanyAccountsCubit>().deleteAccount(account.id);
                              },
                              itemBuilder: (context) =>[
                                const PopupMenuItem(value: 'edit', child: Row(children:[Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('تعديل')])),
                                const PopupMenuItem(value: 'delete', child: Row(children:[Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('حذف', style: TextStyle(color: Colors.red))])),
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('عملة: $currency', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
                    Text('الإجمالي: ${NumberFormat('#,##0.##').format(totalForCurrency)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final hasEditPermission = (authState is AuthAuthenticated) ? authState.user.permissions.companyAccountsEdit : false;

    return BlocProvider(
      create: (context) => CompanyAccountsCubit(context.read<CompanyAccountsRepository>()),
      child: Scaffold(
        body: Column(
          children:[
            TabBar(
              controller: _tabController, labelColor: Colors.teal, unselectedLabelColor: Colors.grey, indicatorColor: Colors.teal,
              tabs: const[Tab(text: 'الموردون'), Tab(text: 'الزبائن'), Tab(text: 'حسابات أخرى')],
            ),
            Expanded(
              child: BlocBuilder<CompanyAccountsCubit, CompanyAccountsState>(
                builder: (context, state) {
                  if (state is CompanyAccountsLoading) return const Center(child: CircularProgressIndicator());
                  if (state is CompanyAccountsError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                  if (state is CompanyAccountsLoaded) {
                    return Stack(
                      children: [
                        TabBarView(
                          controller: _tabController,
                          children:[
                            _buildTabContent(context, state, 'supplier', hasEditPermission),
                            _buildTabContent(context, state, 'customer', hasEditPermission),
                            _buildTabContent(context, state, 'others', hasEditPermission),
                          ],
                        ),
                        if (hasEditPermission)
                          Positioned(
                            bottom: 16, right: 16,
                            child: FloatingActionButton(
                              backgroundColor: Colors.teal,
                              onPressed: () {
                                int nextIndex = state.accounts.length;
                                String defType = 'supplier';
                                if (_tabController.index == 1) defType = 'customer';
                                if (_tabController.index == 2) defType = 'others';
                                _showAccountFormDialog(context, nextOrderIndex: nextIndex, defaultType: defType);
                              },
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// الشاشة الجديدة: تكلفة المواد (إدارة كاملة، سحب وإفلات، تبويبات)
// =========================================================================
class _ProductsCostView extends StatefulWidget {
  final bool hasEditPermission;
  const _ProductsCostView({Key? key, required this.hasEditPermission}) : super(key: key);

  @override
  State<_ProductsCostView> createState() => _ProductsCostViewState();
}

class _ProductsCostViewState extends State<_ProductsCostView> {
  String? _currentTab;

  String _formatNum(double num) => NumberFormat('#,##0.##').format(num);

  void _showMaterialDialog(BuildContext context, CostMaterialsCubit cubit, {CostMaterialModel? material, String tab = 'عام', int col = 0, int row = 0}) {
    if (!widget.hasEditPermission) return;

    final isEdit = material != null;
    final nameCtrl = TextEditingController(text: material?.name ?? '');
    final priceCtrl = TextEditingController(text: material?.price.toString() ?? '0');
    final curCtrl = TextEditingController(text: material?.currency ?? '');
    final tabCtrl = TextEditingController(text: material?.tabName ?? tab);
    final colCtrl = TextEditingController(text: ((material?.columnIndex ?? col) + 1).toString());

    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text(isEdit ? 'تعديل التكلفة' : 'إضافة مادة', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المادة (مثال: ظرف جبنة)', border: OutlineInputBorder())), const SizedBox(height: 12),
              Row(children:[
                Expanded(flex: 2, child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'التكلفة', border: OutlineInputBorder()))), const SizedBox(width: 8),
                Expanded(child: TextField(controller: curCtrl, decoration: const InputDecoration(labelText: 'العملة', border: OutlineInputBorder()))),
              ]), const SizedBox(height: 12),
              Row(children:[
                Expanded(flex: 2, child: TextField(controller: tabCtrl, decoration: const InputDecoration(labelText: 'التبويب', border: OutlineInputBorder()))), const SizedBox(width: 8),
                Expanded(child: TextField(controller: colCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'العمود', border: OutlineInputBorder()))),
              ]),
            ],
          ),
        ),
        actions:[
          if (isEdit) TextButton(onPressed: () { cubit.deleteMaterial(material.id); Navigator.pop(ctx); }, child: const Text('حذف', style: TextStyle(color: Colors.red))),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              final m = CostMaterialModel(
                id: material?.id ?? '', name: nameCtrl.text.trim(), price: double.tryParse(priceCtrl.text) ?? 0, currency: curCtrl.text.trim(),
                tabName: tabCtrl.text.trim(), columnIndex: (int.tryParse(colCtrl.text) ?? 1) - 1, rowIndex: material?.rowIndex ?? row, isSynced: false,
              );
              cubit.saveMaterial(m, !isEdit);
              Navigator.pop(ctx);
            },
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CostMaterialsCubit(context.read<CompanyAccountsRepository>()),
      child: BlocBuilder<CostMaterialsCubit, CostMaterialsState>(
        builder: (context, state) {
          if (state is! CMLoaded) return const Center(child: CircularProgressIndicator());

          final cubit = context.read<CostMaterialsCubit>();
          final materials = state.materials;

          final Map<String, Map<int, List<CostMaterialModel>>> tabsMap = {};
          for (var p in materials) {
            final tName = p.tabName.isEmpty ? '' : p.tabName;
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
                toolbarHeight: 0, // إخفاء العنوان الأساسي لنوفر مساحة
                bottom: tabNames.isEmpty ? null : TabBar(
                  isScrollable: true, labelColor: Colors.teal, indicatorColor: Colors.teal,
                  onTap: (index) => setState(() => _currentTab = tabNames[index]),
                  tabs: tabNames.map((tName) {
                    return DragTarget<CostMaterialModel>(
                      onAccept: (item) {
                        if (item.tabName != tName && widget.hasEditPermission) {
                          cubit.moveMaterial(item.id, tName, 0, 999);
                        }
                      },
                      builder: (context, candidateData, rejectedData) => Tab(
                        child: Container(color: candidateData.isNotEmpty ? Colors.orange.withOpacity(0.3) : Colors.transparent, padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(tName)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              body: tabNames.isEmpty
                  ? const Center(child: Text('لا توجد مواد مسجلة'))
                  : TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: tabNames.map((tName) {
                  final cols = tabsMap[tName]!;
                  int maxCol = cols.keys.isEmpty ? 0 : cols.keys.reduce((a, b) => a > b ? a : b);

                  return SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(maxCol + 2, (cIdx) {
                        final colItems = cols[cIdx] ??[];
                        return Expanded(
                          child: DragTarget<CostMaterialModel>(
                            onAccept: (item) {
                              if (widget.hasEditPermission && (item.columnIndex != cIdx || item.tabName != tName)) {
                                cubit.moveMaterial(item.id, tName, cIdx, colItems.length);
                              }
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                constraints: const BoxConstraints(minHeight: 500),
                                color: candidateData.isNotEmpty ? Colors.teal.shade50 : Colors.transparent,
                                child: Column(
                                  children:[
                                    Container(width: double.infinity, padding: const EdgeInsets.all(8), color: Colors.blueGrey.shade100, child: Text('العمود ${cIdx + 1}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    ...colItems.asMap().entries.map((entry) {
                                      final m = entry.value;
                                      final bgColor = entry.key % 2 == 0 ? Colors.white : Colors.grey.shade50;

                                      Widget cardContent = InkWell(
                                        onTap: () => _showMaterialDialog(context, cubit, material: m),
                                        child: Container(
                                          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                          decoration: BoxDecoration(color: bgColor, border: Border.all(color: Colors.grey.shade300, width: 0.5)),
                                          child: Column(
                                            children:[
                                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                Text(m.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                                                if (!m.isSynced) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.cloud_off, color: Colors.orange, size: 14)),
                                              ]),
                                              const SizedBox(height: 4),
                                              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(4)), child: Text('${_formatNum(m.price)} ${m.currency}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal))),
                                            ],
                                          ),
                                        ),
                                      );

                                      return widget.hasEditPermission ? LongPressDraggable<CostMaterialModel>(
                                        data: m, feedback: Material(elevation: 8, child: Container(padding: const EdgeInsets.all(12), color: Colors.orange.shade100, child: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)))),
                                        childWhenDragging: Container(height: 50, color: Colors.grey.shade300),
                                        child: cardContent,
                                      ) : cardContent;
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
              floatingActionButton: widget.hasEditPermission ? FloatingActionButton(
                backgroundColor: Colors.teal,
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  String tab = _currentTab ?? '';
                  int col = 0; int row = 0;
                  if (tabsMap.containsKey(tab)) {
                    final cols = tabsMap[tab]!;
                    if (cols.isNotEmpty) { col = cols.keys.reduce((a, b) => a > b ? a : b); row = cols[col]!.length; }
                  }
                  _showMaterialDialog(context, context.read<CostMaterialsCubit>(), tab: tab, col: col, row: row);
                },
              ) : null,
            ),
          );
        },
      ),
    );
  }
}