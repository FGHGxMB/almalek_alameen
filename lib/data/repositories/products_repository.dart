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

  // الآلية الجوهرية للتحقق من الإصدار وتحديث البيانات المحلية (تُستدعى عند فتح التطبيق)
  Future<void> syncProductsAndAreas() async {
    try {
      final configDoc = await _firestore
          .collection(FirestoreKeys.settings)
          .doc(FirestoreKeys.appConfigDoc)
          .get();

      if (!configDoc.exists) return;

      final data = configDoc.data()!;
      final serverProductsVersion = data[FirestoreKeys.productsVersion] ?? 0;
      final serverAreasVersion = data[FirestoreKeys.areasVersion] ?? 0;

      // تحديث المواد (Products)
      if (serverProductsVersion > _productsCache.localVersion) {
        final productsSnapshot = await _firestore.collection(FirestoreKeys.products).get();
        final serverProducts = productsSnapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList();

        await _productsCache.saveProducts(serverProducts);
        await _productsCache.setLocalVersion(serverProductsVersion);
      }

      // تحديث المناطق (Areas)
      if (serverAreasVersion > _areasCache.localVersion) {
        final areasList = List<String>.from(data[FirestoreKeys.areas] ??[]);
        await _areasCache.saveAreas(areasList);
        await _areasCache.setLocalVersion(serverAreasVersion);
      }
    } catch (e) {
      // في حالة عدم توفر الإنترنت سيتخطى هذا التحديث بصمت، وسيعتمد على الكاش المحلي
    }
  }

  // إرجاع المواد المحفوظة محلياً للواجهة (بدون انترنت)
  Future<List<ProductModel>> getLocalProducts() async {
    return await _productsCache.getActiveProducts();
  }

  // إرجاع المناطق المحفوظة محلياً للواجهة (بدون انترنت)
  List<String> getLocalAreas() {
    return _areasCache.getAreas();
  }
}