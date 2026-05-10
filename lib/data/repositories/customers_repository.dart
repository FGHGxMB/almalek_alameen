// lib/data/repositories/customers_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';
import '../../core/utils/account_code_generator.dart';
import '../../core/utils/customer_name_builder.dart';
import '../models/customer_model.dart';
import '../models/user_model.dart';

class CustomersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CustomerModel>> getCustomersStream(UserModel currentUser) {
    final delegateIds = [currentUser.id, ...currentUser.canMonitor];
    return _firestore.collection(FirestoreKeys.customers)
        .where(FirestoreKeys.delegateId, whereIn: delegateIds)
        .snapshots(includeMetadataChanges: true) // <--- السحر هنا!
        .map((snapshot) => snapshot.docs.map((doc) => CustomerModel.fromFirestore(doc)).toList());
  }

  // دالة فحص الاسم المكرر
  Future<bool> _isNameDuplicate(String delegateId, String builtName, {String? excludeCustomerId}) async {
    final snap = await _firestore.collection(FirestoreKeys.customers)
        .where(FirestoreKeys.delegateId, isEqualTo: delegateId)
        .where(FirestoreKeys.customerName, isEqualTo: builtName).get();
    if (excludeCustomerId != null) {
      return snap.docs.where((doc) => doc.id != excludeCustomerId).isNotEmpty;
    }
    return snap.docs.isNotEmpty;
  }

  Future<void> createCustomer({
    required UserModel currentUser, required String targetDelegateId, required String country, required String city,
    required String rawName, required String phone1, required String phone2, required String email,
    required String notes, required String region, required String district, required String street,
    required String gender, required double previousBalance,
  }) async {
    // 1. جلب بيانات المندوب (الهدف) من السيرفر مباشرة لضمان أحدث عداد
    final delegateRef = _firestore.collection(FirestoreKeys.users).doc(targetDelegateId);
    final delegateSnap = await delegateRef.get();
    if (!delegateSnap.exists) throw Exception('المندوب غير موجود');

    final delegateData = delegateSnap.data()!;
    final currentCounter = delegateData[FirestoreKeys.customerCounter] ?? 0;
    final newCounter = currentCounter + 1;
    final mainAccount = delegateData[FirestoreKeys.mainCustomerAccount] ?? '';
    final suffix = delegateData[FirestoreKeys.customerSuffix] ?? '';

    final accountCode = AccountCodeGenerator.generate(mainAccount, newCounter);
    final fullName = CustomerNameBuilder.build(suffix: suffix, name: rawName, region: region);

    // 2. فحص التكرار
    if (await _isNameDuplicate(targetDelegateId, fullName)) throw Exception('يوجد زبون بنفس الاسم والمنطقة مسجل مسبقاً لهذا المندوب!');

    // 3. التسجيل
    final batch = _firestore.batch();
    final newCustomerRef = _firestore.collection(FirestoreKeys.customers).doc();
    final newCustomer = CustomerModel(
      id: newCustomerRef.id, accountCode: accountCode, customerName: fullName, phone1: phone1, phone2: phone2, email: email,
      notes: notes, country: country, city: city, region: region, district: district, street: street, gender: gender,
      previousBalance: previousBalance, balance: previousBalance, delegateId: targetDelegateId,
      lastTransactionDate: DateTime.now(),
      isSynced: false,
    );

    batch.set(newCustomerRef, newCustomer.toFirestore());
    batch.update(delegateRef, {FirestoreKeys.customerCounter: newCounter}); // نحدث للرقم الفعلي الذي قرأناه
    await batch.commit();
  }

  Future<void> updateCustomer({
    required CustomerModel customer, required String rawName, required String suffix,
  }) async {
    final fullName = CustomerNameBuilder.build(suffix: suffix, name: rawName, region: customer.region);

    if (await _isNameDuplicate(customer.delegateId, fullName, excludeCustomerId: customer.id)) {
      throw Exception('يوجد زبون بنفس الاسم والمنطقة مسجل مسبقاً!');
    }

    final updated = customer.copyWith(customerName: fullName);
    await _firestore.collection(FirestoreKeys.customers).doc(customer.id).update(updated.toFirestore());
  }

  Future<void> deleteCustomer(String id) async {
    // يفضل التحقق من عدم وجود فواتير مرتبطة به، ولكن للتبسيط سنحذفه مباشرة بناء على طلبك
    await _firestore.collection(FirestoreKeys.customers).doc(id).delete();
  }

  // فحص هل يمتلك الزبون حركات (فواتير، مرتجعات، سندات)
  Future<bool> hasTransactions(String customerId) async {
    final invSnap = await _firestore.collection(FirestoreKeys.invoices).where(FirestoreKeys.customerId, isEqualTo: customerId).limit(1).get();
    if (invSnap.docs.isNotEmpty) return true;

    final retSnap = await _firestore.collection(FirestoreKeys.returns).where(FirestoreKeys.customerId, isEqualTo: customerId).limit(1).get();
    if (retSnap.docs.isNotEmpty) return true;

    final recSnap = await _firestore.collection(FirestoreKeys.receipts).where('creditor_account', isEqualTo: customerId).limit(1).get();
    if (recSnap.docs.isNotEmpty) return true;

    return false;
  }
}