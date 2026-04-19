// lib/data/repositories/customers_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';
import '../../core/utils/account_code_generator.dart';
import '../../core/utils/customer_name_builder.dart';
import '../models/customer_model.dart';
import '../models/user_model.dart';

class CustomersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. جلب الزبائن بشكل حي (Stream) استناداً إلى صلاحية can_monitor
  Stream<List<CustomerModel>> getCustomersStream(UserModel currentUser) {
    // قائمة تحتوي على UID الخاص بالمندوب + UID للمندوبين الذين يحق له مراقبتهم
    final delegateIds = [currentUser.id, ...currentUser.canMonitor];

    return _firestore
        .collection(FirestoreKeys.customers)
        .where(FirestoreKeys.delegateId, whereIn: delegateIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CustomerModel.fromFirestore(doc))
        .toList());
  }

  // 2. إضافة زبون جديد (معالجة الأرقام وبناء الاسم داخل Transaction لضمان سلامة العداد)
  Future<void> createCustomer({
    required UserModel currentUser,
    required String rawName, // الاسم الذي أدخله المندوب
    required String phone1,
    required String phone2,
    required String email,
    required String notes,
    required String region,
    required String district,
    required String street,
    required String gender,
    required double previousBalance,
  }) async {
    final userRef = _firestore.collection(FirestoreKeys.users).doc(currentUser.id);
    final settingsRef = _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc);
    final newCustomerRef = _firestore.collection(FirestoreKeys.customers).doc();

    await _firestore.runTransaction((transaction) async {
      // قراءة بيانات المستخدم الحالي لجلب العداد
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw Exception('بيانات المستخدم غير موجودة.');
      }
      final userData = userSnapshot.data()!;
      final currentCounter = userData[FirestoreKeys.customerCounter] ?? 0;
      final newCounter = currentCounter + 1;

      // قراءة الإعدادات العامة لجلب الدولة والمدينة الثابتة
      final settingsSnapshot = await transaction.get(settingsRef);
      final country = settingsSnapshot.exists ? (settingsSnapshot.data()?['country'] ?? '') : '';
      final city = settingsSnapshot.exists ? (settingsSnapshot.data()?['city'] ?? '') : '';

      // توليد الرمز والاسم
      final mainAccount = userData[FirestoreKeys.mainCustomerAccount] ?? '';
      final suffix = userData[FirestoreKeys.customerSuffix] ?? '';

      final accountCode = AccountCodeGenerator.generate(mainAccount, newCounter);
      final fullName = CustomerNameBuilder.build(
        suffix: suffix,
        name: rawName,
        region: region,
      );

      // إنشاء نموذج الزبون
      final newCustomer = CustomerModel(
        id: newCustomerRef.id,
        accountCode: accountCode,
        customerName: fullName,
        phone1: phone1,
        phone2: phone2,
        email: email,
        notes: notes,
        country: country,
        city: city,
        region: region,
        district: district,
        street: street,
        gender: gender,
        previousBalance: previousBalance,
        balance: previousBalance, // الرصيد السابق يصبح الرصيد الحالي مباشرة (كما طُلب في الخطة)
        delegateId: currentUser.id,
      );

      // حفظ الزبون وتحديث العداد في نفس اللحظة
      transaction.set(newCustomerRef, newCustomer.toFirestore());
      transaction.update(userRef, {
        FirestoreKeys.customerCounter: newCounter,
      });
    });
  }

  // 3. تعديل بيانات زبون موجود
  Future<void> updateCustomer(CustomerModel customer) async {
    await _firestore
        .collection(FirestoreKeys.customers)
        .doc(customer.id)
        .update(customer.toFirestore());
  }

  // 4. حذف زبون
  Future<void> deleteCustomer(String customerId) async {
    await _firestore.collection(FirestoreKeys.customers).doc(customerId).delete();
  }
}