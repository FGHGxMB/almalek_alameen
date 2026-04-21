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
}