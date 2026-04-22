// lib/data/repositories/company_accounts_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';
import '../models/company_account_model.dart';

class CompanyAccountsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب حسابات الشركة مرتبة محلياً حسب order_index
  Stream<List<CompanyAccountModel>> getCompanyAccountsStream() {
    return _firestore
        .collection(FirestoreKeys.companyAccounts)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => CompanyAccountModel.fromFirestore(doc)).toList();
      list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return list;
    });
  }

  // إضافة حساب شركة جديد
  Future<void> createCompanyAccount({
    required String name, required String type, required double initialBalance,
    required String currency, required String themeColor, required String bgColor,
    required int newOrderIndex,
  }) async {
    final docRef = _firestore.collection(FirestoreKeys.companyAccounts).doc();

    final account = CompanyAccountModel(
      id: docRef.id, accountName: name, balance: initialBalance, currency: currency,
      accountType: type, themeColor: themeColor, backgroundColor: bgColor,
      orderIndex: newOrderIndex,
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );
    await docRef.set(account.toFirestore());
  }

  // تعديل حساب موجود
  Future<void> updateCompanyAccount({
    required String id, required String name, required double balance,
    required String currency, required String themeColor, required String bgColor,
  }) async {
    await _firestore.collection(FirestoreKeys.companyAccounts).doc(id).update({
      FirestoreKeys.accountName: name,
      FirestoreKeys.balance: balance,
      'currency': currency,
      'theme_color': themeColor,
      'background_color': bgColor,
      FirestoreKeys.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  // حذف حساب
  Future<void> deleteCompanyAccount(String id) async {
    await _firestore.collection(FirestoreKeys.companyAccounts).doc(id).delete();
  }

  // حفظ الترتيب الجديد (عملية Batch جماعية سريعة وتدعم الأوفلاين)
  Future<void> reorderAccounts(List<CompanyAccountModel> updatedList) async {
    final batch = _firestore.batch();
    for (int i = 0; i < updatedList.length; i++) {
      final docRef = _firestore.collection(FirestoreKeys.companyAccounts).doc(updatedList[i].id);
      batch.update(docRef, {'order_index': i});
    }
    await batch.commit();
  }
}