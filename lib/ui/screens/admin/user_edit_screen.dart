// lib/ui/screens/admin/user_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../core/constants/firestore_keys.dart';

class UserEditScreen extends StatefulWidget {
  final UserModel? user;
  final List<UserModel> allUsers;
  const UserEditScreen({Key? key, this.user, required this.allUsers}) : super(key: key);
  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rankController = TextEditingController();
  final _warehouseController = TextEditingController();
  final _mainAccountController = TextEditingController();
  final _costCenterController = TextEditingController();
  final _suffixController = TextEditingController();

  bool _isActive = true;
  List<String> _canMonitor =[];
  bool _isLoading = false;
  Color _selectedColor = Colors.orange;

  final List<Color> _userColors = const[
    Colors.orange, Colors.blue, Colors.red, Colors.green, Colors.purple,
    Colors.brown, Colors.teal, Colors.pink, Colors.indigo, Colors.amber,
  ];

  final Map<String, bool> _perms = {
    'adminAccess': false, 'exportData': false, 'companyAccountsView': false, 'companyAccountsEdit': false,
    'invoiceCreate': false, 'invoiceEdit': false, 'invoiceDelete': false,
    'returnCreate': false, 'returnEdit': false, 'returnDelete': false,
    'receiptCreate': false, 'receiptEdit': false, 'receiptDelete': false,
    'customerCreate': false, 'customerEdit': false, 'customerDelete': false,
    // الـ 12 صلاحية الجديدة للمراقبين
    'customerCreateMonitored': false, 'customerEditMonitored': false, 'customerDeleteMonitored': false,
    'invoiceCreateMonitored': false, 'invoiceEditMonitored': false, 'invoiceDeleteMonitored': false,
    'returnCreateMonitored': false, 'returnEditMonitored': false, 'returnDeleteMonitored': false,
    'receiptCreateMonitored': false, 'receiptEditMonitored': false, 'receiptDeleteMonitored': false,
    'updateCurrency': false,
  };

  Color _hexToColor(String hex) {
    try { return Color(int.parse(hex.replaceFirst('#', 'ff'), radix: 16)); } catch(e) { return Colors.orange; }
  }
  String _colorToHex(Color color) => '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      final u = widget.user!;
      _nameController.text = u.accountName; _emailController.text = u.email;
      _rankController.text = u.rank; _warehouseController.text = u.warehouseCode;
      _mainAccountController.text = u.mainCustomerAccount; _costCenterController.text = u.costCenterCode;
      _suffixController.text = u.customerSuffix; _isActive = u.isActive;
      _canMonitor = List.from(u.canMonitor);
      _selectedColor = _hexToColor(u.accountColor);

      _perms['adminAccess'] = u.permissions.adminAccess; _perms['exportData'] = u.permissions.exportData;
      _perms['companyAccountsView'] = u.permissions.companyAccountsView; _perms['companyAccountsEdit'] = u.permissions.companyAccountsEdit;
      _perms['invoiceCreate'] = u.permissions.invoiceCreate; _perms['invoiceEdit'] = u.permissions.invoiceEdit; _perms['invoiceDelete'] = u.permissions.invoiceDelete;
      _perms['returnCreate'] = u.permissions.returnCreate; _perms['returnEdit'] = u.permissions.returnEdit; _perms['returnDelete'] = u.permissions.returnDelete;
      _perms['receiptCreate'] = u.permissions.receiptCreate; _perms['receiptEdit'] = u.permissions.receiptEdit; _perms['receiptDelete'] = u.permissions.receiptDelete;
      _perms['customerCreate'] = u.permissions.customerCreate; _perms['customerEdit'] = u.permissions.customerEdit; _perms['customerDelete'] = u.permissions.customerDelete;
      _perms['customerCreateMonitored'] = u.permissions.customerCreateMonitored; _perms['customerEditMonitored'] = u.permissions.customerEditMonitored; _perms['customerDeleteMonitored'] = u.permissions.customerDeleteMonitored;
      _perms['invoiceCreateMonitored'] = u.permissions.invoiceCreateMonitored; _perms['invoiceEditMonitored'] = u.permissions.invoiceEditMonitored; _perms['invoiceDeleteMonitored'] = u.permissions.invoiceDeleteMonitored;
      _perms['returnCreateMonitored'] = u.permissions.returnCreateMonitored; _perms['returnEditMonitored'] = u.permissions.returnEditMonitored; _perms['returnDeleteMonitored'] = u.permissions.returnDeleteMonitored;
      _perms['receiptCreateMonitored'] = u.permissions.receiptCreateMonitored; _perms['receiptEditMonitored'] = u.permissions.receiptEditMonitored; _perms['receiptDeleteMonitored'] = u.permissions.receiptDeleteMonitored;
      _perms['updateCurrency'] = u.permissions.updateCurrency;
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final repo = context.read<AdminRepository>();
      final permissionsMap = {
        'admin_access': _perms['adminAccess'], 'export_data': _perms['exportData'],
        'company_accounts_view': _perms['companyAccountsView'], 'company_accounts_edit': _perms['companyAccountsEdit'],
        'invoice_create': _perms['invoiceCreate'], 'invoice_edit': _perms['invoiceEdit'], 'invoice_delete': _perms['invoiceDelete'],
        'return_create': _perms['returnCreate'], 'return_edit': _perms['returnEdit'], 'return_delete': _perms['returnDelete'],
        'receipt_create': _perms['receiptCreate'], 'receipt_edit': _perms['receiptEdit'], 'receipt_delete': _perms['receiptDelete'],
        'customer_create': _perms['customerCreate'], 'customer_edit': _perms['customerEdit'], 'customer_delete': _perms['customerDelete'],
        'customer_create_monitored': _perms['customerCreateMonitored'], 'customer_edit_monitored': _perms['customerEditMonitored'], 'customer_delete_monitored': _perms['customerDeleteMonitored'],
        'invoice_create_monitored': _perms['invoiceCreateMonitored'], 'invoice_edit_monitored': _perms['invoiceEditMonitored'], 'invoice_delete_monitored': _perms['invoiceDeleteMonitored'],
        'return_create_monitored': _perms['returnCreateMonitored'], 'return_edit_monitored': _perms['returnEditMonitored'], 'return_delete_monitored': _perms['returnDeleteMonitored'],
        'receipt_create_monitored': _perms['receiptCreateMonitored'], 'receipt_edit_monitored': _perms['receiptEditMonitored'], 'receipt_delete_monitored': _perms['receiptDeleteMonitored'],
        'update_currency': _perms['updateCurrency'],
      };

      final userData = {
        FirestoreKeys.accountName: _nameController.text.trim(), FirestoreKeys.rank: _rankController.text.trim(),
        FirestoreKeys.warehouseCode: _warehouseController.text.trim(), FirestoreKeys.mainCustomerAccount: _mainAccountController.text.trim(),
        FirestoreKeys.costCenterCode: _costCenterController.text.trim(), FirestoreKeys.customerSuffix: _suffixController.text.trim(),
        FirestoreKeys.isActive: _isActive, FirestoreKeys.canMonitor: _canMonitor, FirestoreKeys.permissions: permissionsMap,
        FirestoreKeys.accountColor: _colorToHex(_selectedColor), // حفظ اللون
      };

      if (widget.user == null) {
        userData[FirestoreKeys.delegateInvoiceCounter] = 0; userData[FirestoreKeys.delegateReturnCounter] = 0;
        userData[FirestoreKeys.delegateReceiptCounter] = 0; userData[FirestoreKeys.customerCounter] = 0;
        await repo.createUser(email: _emailController.text.trim(), password: _passwordController.text.trim(), userData: userData);
      } else {
        await repo.updateUser(widget.user!.id, userData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح'), backgroundColor: Colors.green));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildToggle(String title, String key) => SwitchListTile(title: Text(title, style: const TextStyle(fontSize: 14)), value: _perms[key]!, onChanged: (val) => setState(() => _perms[key] = val), dense: true);

  @override
  Widget build(BuildContext context) {
    final isNew = widget.user == null;
    return Scaffold(
      appBar: AppBar(title: Text(isNew ? 'إضافة مستخدم' : 'تعديل ${widget.user!.accountName}')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              const Text('المعلومات الأساسية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 12),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'الاسم (Account Name)', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _emailController, readOnly: !isNew, decoration: InputDecoration(labelText: 'البريد الإلكتروني', border: const OutlineInputBorder(), filled: !isNew), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              if (isNew) const SizedBox(height: 12),
              if (isNew) TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder()), validator: (v) => v!.length < 6 ? 'أقل شيء 6 حروف' : null),
              const SizedBox(height: 12),

              const Text('لون تمييز الحساب (يظهر تحت زبائنه للمراقبين):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _userColors.map((c) => InkWell(
                  onTap: () => setState(() => _selectedColor = c),
                  child: CircleAvatar(backgroundColor: c, radius: 16, child: _selectedColor == c ? const Icon(Icons.check, color: Colors.white, size: 20) : null),
                )).toList(),
              ),
              const SizedBox(height: 12),

              TextFormField(controller: _rankController, decoration: const InputDecoration(labelText: 'الرتبة (Rank)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(children:[Expanded(child: TextFormField(controller: _warehouseController, decoration: const InputDecoration(labelText: 'رمز المستودع', border: OutlineInputBorder()))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _costCenterController, decoration: const InputDecoration(labelText: 'مركز الكلفة', border: OutlineInputBorder())))]),
              const SizedBox(height: 12),
              Row(children:[Expanded(child: TextFormField(controller: _mainAccountController, decoration: const InputDecoration(labelText: 'بادئة حساب الزبائن (مثال: 102)', border: OutlineInputBorder()))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _suffixController, decoration: const InputDecoration(labelText: 'لاحقة اسم الزبون (مثال: متجر)', border: OutlineInputBorder())))]),
              const SizedBox(height: 12),
              SwitchListTile(title: const Text('حساب مفعل (نشط)', style: TextStyle(fontWeight: FontWeight.bold)), value: _isActive, onChanged: (val) => setState(() => _isActive = val), activeColor: Colors.teal),
              const Divider(height: 32, thickness: 2),

              const Text('صلاحيات المراقبة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)), height: 150,
                child: ListView(children: widget.allUsers.where((u) => u.id != widget.user?.id).map((u) {
                  return CheckboxListTile(title: Text(u.accountName), subtitle: Text(u.rank), value: _canMonitor.contains(u.id), onChanged: (bool? c) { setState(() { if (c == true) _canMonitor.add(u.id); else _canMonitor.remove(u.id); }); });
                }).toList()),
              ),
              const Divider(height: 32, thickness: 2),

              const Text('الصلاحيات الأساسية (لحسابه الخاص)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              _buildToggle('لوحة الإدارة', 'adminAccess'), _buildToggle('تصدير Excel', 'exportData'),
              _buildToggle('عرض حسابات الشركة', 'companyAccountsView'), _buildToggle('تعديل حسابات الشركة', 'companyAccountsEdit'), _buildToggle('تعديل سعر الدولار', 'updateCurrency'),
              const Divider(),
              _buildToggle('إضافة زبون', 'customerCreate'), _buildToggle('تعديل زبون', 'customerEdit'), _buildToggle('حذف زبون', 'customerDelete'),
              _buildToggle('إنشاء فاتورة', 'invoiceCreate'), _buildToggle('تعديل فاتورة', 'invoiceEdit'), _buildToggle('حذف فاتورة', 'invoiceDelete'),
              _buildToggle('إنشاء مرتجع', 'returnCreate'), _buildToggle('تعديل مرتجع', 'returnEdit'), _buildToggle('حذف مرتجع', 'returnDelete'),
              _buildToggle('إنشاء سند', 'receiptCreate'), _buildToggle('تعديل سند', 'receiptEdit'), _buildToggle('حذف سند', 'receiptDelete'),

              const Divider(height: 32, thickness: 2),
              const Text('صلاحيات متقدمة (لحسابات المراقبين)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
              _buildToggle('إضافة زبون لغيره', 'customerCreateMonitored'), _buildToggle('تعديل زبون لغيره', 'customerEditMonitored'), _buildToggle('حذف زبون لغيره', 'customerDeleteMonitored'),
              _buildToggle('إنشاء فاتورة لغيره', 'invoiceCreateMonitored'), _buildToggle('تعديل فاتورة لغيره', 'invoiceEditMonitored'), _buildToggle('حذف فاتورة لغيره', 'invoiceDeleteMonitored'),
              _buildToggle('إنشاء مرتجع لغيره', 'returnCreateMonitored'), _buildToggle('تعديل مرتجع لغيره', 'returnEditMonitored'), _buildToggle('حذف مرتجع لغيره', 'returnDeleteMonitored'),
              _buildToggle('إنشاء سند لغيره', 'receiptCreateMonitored'), _buildToggle('تعديل سند لغيره', 'receiptEditMonitored'), _buildToggle('حذف سند لغيره', 'receiptDeleteMonitored'),

              const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveUser, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.teal), child: const Text('حفظ بيانات المستخدم', style: TextStyle(fontSize: 18, color: Colors.white)))),
            ],
          ),
        ),
      ),
    );
  }
}