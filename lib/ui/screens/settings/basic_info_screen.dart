// lib/ui/screens/settings/basic_info_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/settings/basic_info_cubit.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({Key? key}) : super(key: key);

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _mainCashAccountCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _printMessageCtrl = TextEditingController(); // نص الطباعة

  @override
  void dispose() {
    _mainCashAccountCtrl.dispose(); _countryCtrl.dispose();
    _cityCtrl.dispose(); _printMessageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BasicInfoCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('المعلومات الأساسية للمؤسسة'), centerTitle: true),
        body: BlocConsumer<BasicInfoCubit, BasicInfoState>(
          listener: (context, state) {
            if (state is BasicInfoSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الإعدادات بنجاح'), backgroundColor: Colors.green));
              context.pop();
            } else if (state is BasicInfoError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state is BasicInfoLoading) return const Center(child: CircularProgressIndicator());

            if (state is BasicInfoLoaded) {
              // تعبئة الحقول بالبيانات الحالية
              _mainCashAccountCtrl.text = state.configData['main_cash_account'] ?? '';
              _countryCtrl.text = state.configData['country'] ?? '';
              _cityCtrl.text = state.configData['city'] ?? '';
              _printMessageCtrl.text = state.configData['print_message'] ?? ''; // الحقل الجديد للطباعة

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      // 1. معلومات الحسابات
                      const Text('إعدادات الحسابات والموقع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _mainCashAccountCtrl,
                        decoration: const InputDecoration(labelText: 'رمز حساب الصندوق الرئيسي', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children:[
                          Expanded(child: TextFormField(controller: _countryCtrl, decoration: const InputDecoration(labelText: 'الدولة (الافتراضية للزبائن)', border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'المدينة (الافتراضية)', border: OutlineInputBorder()))),
                        ],
                      ),

                      const Divider(height: 32, thickness: 2),

                      // 2. إعدادات الطباعة
                      const Text('إعدادات الفواتير والطباعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                      const SizedBox(height: 12),

                      // حقل اللوغو (معلومة للمدير)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
                        child: Row(
                          children: const[
                            Icon(Icons.image, color: Colors.blue, size: 40),
                            SizedBox(width: 12),
                            Expanded(child: Text('شعار الفواتير (اللوغو) مثبت ومدمج داخل التطبيق ليعمل بدون إنترنت. لتغييره، يجب تبديل ملف assets/print_logo.png في كود التطبيق.', style: TextStyle(fontSize: 12, color: Colors.blue))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _printMessageCtrl,
                        maxLines: 4, // يتيح كتابة عدة أسطر
                        decoration: const InputDecoration(
                          labelText: 'نص التذييل (رسالة ترحيبية أو ملاحظات تظهر أسفل الفاتورة)',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<BasicInfoCubit>().updateData({
                              'main_cash_account': _mainCashAccountCtrl.text.trim(),
                              'country': _countryCtrl.text.trim(),
                              'city': _cityCtrl.text.trim(),
                              'print_message': _printMessageCtrl.text.trim(),
                            });
                          },
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.teal),
                          child: const Text('حفظ التعديلات', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}