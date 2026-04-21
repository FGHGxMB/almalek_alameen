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
  // 2. إضافة زبون جديد (Offline-First باستخدام Batch و FieldValue.increment)
  Future<void> createCustomer({
    required UserModel currentUser,
    required String country, // تم جلبهم من الإعدادات المحفوظة
    required String city,
    required String rawName,
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
    final batch = _firestore.batch();
    final userRef = _firestore.collection(FirestoreKeys.users).doc(currentUser.id);
    final newCustomerRef = _firestore.collection(FirestoreKeys.customers).doc();

    // نستخدم العداد المحلي الموجود في هاتف المندوب للسرعة ولعمله أوفلاين
    final newCounter = currentUser.customerCounter + 1;
    final mainAccount = currentUser.mainCustomerAccount;
    final suffix = currentUser.customerSuffix;

    final accountCode = AccountCodeGenerator.generate(mainAccount, newCounter);
    final fullName = CustomerNameBuilder.build(
      suffix: suffix,
      name: rawName,
      region: region,
    );

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
      balance: previousBalance, // الرصيد السابق يصبح الحالي مباشرة
      delegateId: currentUser.id,
    );

    // كتابة الزبون
    batch.set(newCustomerRef, newCustomer.toFirestore());
    // زيادة العداد في حساب المندوب بشكل آمن
    batch.update(userRef, {FirestoreKeys.customerCounter: FieldValue.increment(1)});

    await batch.commit();
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