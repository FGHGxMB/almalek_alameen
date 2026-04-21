// lib/ui/screens/admin/user_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../core/constants/firestore_keys.dart';

class UserEditScreen extends StatefulWidget {
  final UserModel? user; // إذا كان null يعني إضافة مستخدم جديد
  final List<UserModel> allUsers;

  const UserEditScreen({Key? key, this.user, required this.allUsers}) : super(key: key);

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // للجديد فقط
  final _rankController = TextEditingController();
  final _warehouseController = TextEditingController();
  final _mainAccountController = TextEditingController();
  final _costCenterController = TextEditingController();
  final _suffixController = TextEditingController();

  bool _isActive = true;
  List<String> _canMonitor =[];
  bool _isLoading = false;

  // Permissions Map
  final Map<String, bool> _perms = {
    'adminAccess': false, 'exportData': false, 'companyAccountsView': false,
    'companyAccountsEdit': false, 'invoiceCreate': false, 'invoiceEdit': false,
    'invoiceDelete': false, 'returnCreate': false, 'returnEdit': false,
    'returnDelete': false, 'receiptCreate': false, 'receiptEdit': false,
    'receiptDelete': false, 'customerCreate': false, 'customerEdit': false,
    'customerDelete': false,
  };

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      final u = widget.user!;
      _nameController.text = u.accountName;
      _emailController.text = u.email;
      _rankController.text = u.rank;
      _warehouseController.text = u.warehouseCode;
      _mainAccountController.text = u.mainCustomerAccount;
      _costCenterController.text = u.costCenterCode;
      _suffixController.text = u.customerSuffix;
      _isActive = u.isActive;
      _canMonitor = List.from(u.canMonitor);

      // Load permissions
      _perms['adminAccess'] = u.permissions.adminAccess;
      _perms['exportData'] = u.permissions.exportData;
      _perms['companyAccountsView'] = u.permissions.companyAccountsView;
      _perms['companyAccountsEdit'] = u.permissions.companyAccountsEdit;
      _perms['invoiceCreate'] = u.permissions.invoiceCreate;
      _perms['invoiceEdit'] = u.permissions.invoiceEdit;
      _perms['invoiceDelete'] = u.permissions.invoiceDelete;
      _perms['returnCreate'] = u.permissions.returnCreate;
      _perms['returnEdit'] = u.permissions.returnEdit;
      _perms['returnDelete'] = u.permissions.returnDelete;
      _perms['receiptCreate'] = u.permissions.receiptCreate;
      _perms['receiptEdit'] = u.permissions.receiptEdit;
      _perms['receiptDelete'] = u.permissions.receiptDelete;
      _perms['customerCreate'] = u.permissions.customerCreate;
      _perms['customerEdit'] = u.permissions.customerEdit;
      _perms['customerDelete'] = u.permissions.customerDelete;
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final repo = context.read<AdminRepository>();
      final permissionsMap = {
        'admin_access': _perms['adminAccess'],
        'export_data': _perms['exportData'],
        'company_accounts_view': _perms['companyAccountsView'],
        'company_accounts_edit': _perms['companyAccountsEdit'],
        'invoice_create': _perms['invoiceCreate'],
        'invoice_edit': _perms['invoiceEdit'],
        'invoice_delete': _perms['invoiceDelete'],
        'return_create': _perms['returnCreate'],
        'return_edit': _perms['returnEdit'],
        'return_delete': _perms['returnDelete'],
        'receipt_create': _perms['receiptCreate'],
        'receipt_edit': _perms['receiptEdit'],
        'receipt_delete': _perms['receiptDelete'],
        'customer_create': _perms['customerCreate'],
        'customer_edit': _perms['customerEdit'],
        'customer_delete': _perms['customerDelete'],
      };

      final userData = {
        FirestoreKeys.accountName: _nameController.text.trim(),
        FirestoreKeys.rank: _rankController.text.trim(),
        FirestoreKeys.warehouseCode: _warehouseController.text.trim(),
        FirestoreKeys.mainCustomerAccount: _mainAccountController.text.trim(),
        FirestoreKeys.costCenterCode: _costCenterController.text.trim(),
        FirestoreKeys.customerSuffix: _suffixController.text.trim(),
        FirestoreKeys.isActive: _isActive,
        FirestoreKeys.canMonitor: _canMonitor,
        FirestoreKeys.permissions: permissionsMap,
      };

      if (widget.user == null) {
        // إضافة مستخدم جديد (يجب أن يتم تعيين العدادات لصفر أيضاً)
        userData[FirestoreKeys.delegateInvoiceCounter] = 0;
        userData[FirestoreKeys.delegateReturnCounter] = 0;
        userData[FirestoreKeys.delegateReceiptCounter] = 0;
        userData[FirestoreKeys.customerCounter] = 0;

        await repo.createUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          userData: userData,
        );
      } else {
        // تعديل مستخدم (لا نعدل الإيميل أو الباسورد من هنا لتعقيدها الأمني، نعدل الداتا فقط)
        await repo.updateUser(widget.user!.id, userData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح'), backgroundColor: Colors.green));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildToggle(String title, String key) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: _perms[key]!,
      onChanged: (val) => setState(() => _perms[key] = val),
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.user == null;

    return Scaffold(
      appBar: AppBar(title: Text(isNew ? 'إضافة مستخدم' : 'تعديل ${widget.user!.accountName}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
              const SizedBox(height: 12),
              if (isNew) TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder()), validator: (v) => v!.length < 6 ? 'أقل شيء 6 حروف' : null),
              if (isNew) const SizedBox(height: 12),
              TextFormField(controller: _rankController, decoration: const InputDecoration(labelText: 'الرتبة (Rank)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(
                children:[
                  Expanded(child: TextFormField(controller: _warehouseController, decoration: const InputDecoration(labelText: 'رمز المستودع', border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _costCenterController, decoration: const InputDecoration(labelText: 'مركز الكلفة', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children:[
                  Expanded(child: TextFormField(controller: _mainAccountController, decoration: const InputDecoration(labelText: 'بادئة حساب الزبائن (مثال: 102)', border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _suffixController, decoration: const InputDecoration(labelText: 'لاحقة اسم الزبون (مثال: متجر)', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('حساب مفعل (نشط)', style: TextStyle(fontWeight: FontWeight.bold)),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
                activeColor: Colors.teal,
              ),
              const Divider(height: 32, thickness: 2),

              // قسم المراقبة (can_monitor)
              const Text('صلاحيات المراقبة (يرى زبائن وفواتير هؤلاء)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                height: 150,
                child: ListView(
                  children: widget.allUsers.where((u) => u.id != widget.user?.id).map((u) {
                    return CheckboxListTile(
                      title: Text(u.accountName),
                      subtitle: Text(u.rank),
                      value: _canMonitor.contains(u.id),
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) _canMonitor.add(u.id);
                          else _canMonitor.remove(u.id);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 32, thickness: 2),

              // قسم الصلاحيات التفصيلية (Permissions)
              const Text('الصلاحيات التفصيلية (Permissions)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 8),
              _buildToggle('صلاحية لوحة الإدارة (Admin Access)', 'adminAccess'),
              _buildToggle('تصدير البيانات لـ Excel', 'exportData'),
              const Divider(),
              _buildToggle('عرض حسابات الشركة', 'companyAccountsView'),
              _buildToggle('إضافة/تعديل حسابات الشركة', 'companyAccountsEdit'),
              const Divider(),
              _buildToggle('إنشاء فاتورة مبيعات', 'invoiceCreate'),
              _buildToggle('تعديل فاتورة مبيعات', 'invoiceEdit'),
              _buildToggle('حذف فاتورة مبيعات', 'invoiceDelete'),
              const Divider(),
              _buildToggle('إنشاء مرتجع مبيعات', 'returnCreate'),
              _buildToggle('تعديل مرتجع مبيعات', 'returnEdit'),
              _buildToggle('حذف مرتجع مبيعات', 'returnDelete'),
              const Divider(),
              _buildToggle('إنشاء سند قبض', 'receiptCreate'),
              _buildToggle('تعديل سند قبض', 'receiptEdit'),
              _buildToggle('حذف سند قبض', 'receiptDelete'),
              const Divider(),
              _buildToggle('إنشاء زبون جديد', 'customerCreate'),
              _buildToggle('تعديل بيانات زبون', 'customerEdit'),
              _buildToggle('حذف زبون', 'customerDelete'),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveUser,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.teal),
                  child: const Text('حفظ بيانات المستخدم', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}