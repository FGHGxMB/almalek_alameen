// lib/data/repositories/company_accounts_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';
import '../models/company_account_model.dart';

class CompanyAccountsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب حسابات الشركة كـ Stream حي
  Stream<List<CompanyAccountModel>> getCompanyAccountsStream() {
    return _firestore
        .collection(FirestoreKeys.companyAccounts)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CompanyAccountModel.fromFirestore(doc))
        .toList());
  }

  // إضافة حساب شركة جديد
  Future<void> createCompanyAccount({
    required String name,
    required String type, // 'supplier' أو 'customer'
    required double initialBalance,
  }) async {
    final docRef = _firestore.collection(FirestoreKeys.companyAccounts).doc();

    // تحديد الألوان بناءً على النوع
    final themeColor = type == 'supplier' ? '#E91E63' : '#2196F3'; // وردي للمورد، أزرق للزبون
    final bgColor = type == 'supplier' ? '#FCE4EC' : '#E3F2FD';

    final account = CompanyAccountModel(
      id: docRef.id,
      accountName: name,
      balance: initialBalance,
      accountType: type,
      themeColor: themeColor,
      backgroundColor: bgColor,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(account.toFirestore());
  }
}