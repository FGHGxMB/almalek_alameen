// lib/data/repositories/products_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';
import '../local/products_cache.dart';
import '../local/areas_cache.dart';
import '../models/product_model.dart';

class ProductsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductsCache _productsCache;
  final AreasCache _areasCache;

  ProductsRepository({
    required ProductsCache productsCache,
    required AreasCache areasCache,
  })  : _productsCache = productsCache,
        _areasCache = areasCache;

  // 1. التزامن الحي والمستمر (Real-time Sync)
  // هذه الدالة تراقب إصدار المواد، وبمجرد تغييره تقوم بتحديث الكاش المحلي فوراً بدون إعادة تشغيل التطبيق!
  void listenToVersionChanges() {
    _firestore
        .collection(FirestoreKeys.settings)
        .doc(FirestoreKeys.appConfigDoc)
        .snapshots()
        .listen((configDoc) async {
      if (!configDoc.exists) return;

      final data = configDoc.data()!;
      final serverProductsVersion = data[FirestoreKeys.productsVersion] ?? 0;
      final serverAreasVersion = data[FirestoreKeys.areasVersion] ?? 0;

      // تحديث المواد (Products) بصمت في الخلفية
      if (serverProductsVersion > _productsCache.localVersion) {
        final productsSnapshot = await _firestore.collection(FirestoreKeys.products).get();
        final serverProducts = productsSnapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList();

        await _productsCache.saveProducts(serverProducts);
        await _productsCache.setLocalVersion(serverProductsVersion);
      }

      // تحديث المناطق (Areas) بصمت في الخلفية
      if (serverAreasVersion > _areasCache.localVersion) {
        final areasList = List<String>.from(data[FirestoreKeys.areas] ??[]);
        await _areasCache.saveAreas(areasList);
        await _areasCache.setLocalVersion(serverAreasVersion);
      }
    });
  }

  Future<List<ProductModel>> getLocalProducts() async {
    return await _productsCache.getActiveProducts();
  }

  List<String> getLocalAreas() {
    return _areasCache.getAreas();
  }

  // --- دوال الإدارة (Admin) ---

  Stream<List<ProductModel>> getAdminProductsStream() {
    return _firestore.collection(FirestoreKeys.products)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  void saveProductAdmin(ProductModel product, {bool isNew = false}) {
    final docRef = isNew
        ? _firestore.collection(FirestoreKeys.products).doc()
        : _firestore.collection(FirestoreKeys.products).doc(product.id);

    final updatedProduct = product.copyWith(id: docRef.id);
    docRef.set(updatedProduct.toFirestore(), SetOptions(merge: true));

    // هذا التحديث سيوقظ الدالة listenToVersionChanges() في كل الأجهزة!
    _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc)
        .update({FirestoreKeys.productsVersion: FieldValue.increment(1)});
  }

  void moveProduct(String productId, String newTab, int newCol, int newRow) {
    _firestore.collection(FirestoreKeys.products).doc(productId).update({
      FirestoreKeys.tabName: newTab,
      FirestoreKeys.columnIndex: newCol,
      FirestoreKeys.rowIndex: newRow,
    });

    _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc)
        .update({FirestoreKeys.productsVersion: FieldValue.increment(1)});
  }

  // دالة فحص الاستخدام (ترجع رسالة خطأ مع اسم المندوب إذا كانت مستخدمة، وترجع null إذا كانت متاحة للحذف)
  Future<String?> checkProductUsage(String productId) async {
    const GetOptions serverOnly = GetOptions(source: Source.server);
    try {
      // فحص الفواتير
      final invSnap = await _firestore.collection(FirestoreKeys.invoices).get(serverOnly);
      for (var doc in invSnap.docs) {
        final items = doc.data()[FirestoreKeys.items] as List<dynamic>? ??[];
        for (var item in items) {
          if (item[FirestoreKeys.productId] == productId) {
            String delegateId = doc.data()[FirestoreKeys.delegateId];
            String delegateName = 'مجهول';
            try {
              final userDoc = await _firestore.collection(FirestoreKeys.users).doc(delegateId).get(serverOnly);
              if (userDoc.exists) delegateName = userDoc.data()![FirestoreKeys.accountName];
            } catch(e){}
            return 'لا يمكن الحذف! المادة مستخدمة في فاتورة مبيعات رقم ${doc.data()[FirestoreKeys.delegateInvoiceNumber]} للمندوب: $delegateName';
          }
        }
      }

      // فحص المرتجعات
      final retSnap = await _firestore.collection(FirestoreKeys.returns).get(serverOnly);
      for (var doc in retSnap.docs) {
        final items = doc.data()[FirestoreKeys.items] as List<dynamic>? ??[];
        for (var item in items) {
          if (item[FirestoreKeys.productId] == productId) {
            String delegateId = doc.data()[FirestoreKeys.delegateId];
            String delegateName = 'مجهول';
            try {
              final userDoc = await _firestore.collection(FirestoreKeys.users).doc(delegateId).get(serverOnly);
              if (userDoc.exists) delegateName = userDoc.data()![FirestoreKeys.accountName];
            } catch(e){}
            return 'لا يمكن الحذف! المادة مستخدمة في مرتجع رقم ${doc.data()[FirestoreKeys.delegateReturnNumber]} للمندوب: $delegateName';
          }
        }
      }
      return null; // المادة حرة ويمكن حذفها
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') return 'لا يوجد إنترنت! يُمنع الفحص والحذف في وضع الأوفلاين.';
      return 'خطأ في الفحص: $e';
    }
  }

  // دالة الحذف الفعلي (تُستدعى فقط بعد التأكد)
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection(FirestoreKeys.products).doc(productId).delete();
    await _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc).update({FirestoreKeys.productsVersion: FieldValue.increment(1)});
  }
}