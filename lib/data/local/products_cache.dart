// lib/data/local/products_cache.dart

import 'package:drift/drift.dart';
import '../models/product_model.dart';
import 'app_database.dart';
import 'local_storage.dart';

class ProductsCache {
  final AppDatabase _db;
  final LocalStorage _localStorage;

  ProductsCache(this._db, this._localStorage);

  int get localVersion => _localStorage.prefs.getInt('products_version') ?? 0;

  Future<void> setLocalVersion(int version) async {
    await _localStorage.prefs.setInt('products_version', version);
  }

  Future<void> saveProducts(List<ProductModel> products) async {
    final companions = products.map((p) => ProductsTableCompanion(
      id: Value(p.id),
      itemCode: Value(p.itemCode),
      itemName: Value(p.itemName),
      groupCode: Value(p.groupCode),
      currencyCode: Value(p.currencyCode),
      defaultUnit: Value(p.defaultUnit),
      isActive: Value(p.isActive),
      tabName: Value(p.tabName),
      columnIndex: Value(p.columnIndex),
      rowIndex: Value(p.rowIndex),
      unit1: Value(p.unit1), barcode1: Value(p.barcode1), shopPrice1: Value(p.shopPrice1), consumerPrice1: Value(p.consumerPrice1),
      unit2: Value(p.unit2), barcode2: Value(p.barcode2), shopPrice2: Value(p.shopPrice2), consumerPrice2: Value(p.consumerPrice2),
      unit3: Value(p.unit3), barcode3: Value(p.barcode3), shopPrice3: Value(p.shopPrice3), consumerPrice3: Value(p.consumerPrice3),
      minPrice1: Value(p.minPrice1),
      minPrice2: Value(p.minPrice2),
      minPrice3: Value(p.minPrice3),
    )).toList();

    await _db.replaceAllProducts(companions);
  }

  Future<List<ProductModel>> getActiveProducts() async {
    final rows = await _db.getAllActiveProducts();
    return rows.map((row) => ProductModel(
      id: row.id,
      itemCode: row.itemCode,
      itemName: row.itemName,
      groupCode: row.groupCode,
      currencyCode: row.currencyCode,
      defaultUnit: row.defaultUnit,
      isActive: row.isActive,
      tabName: row.tabName,
      columnIndex: row.columnIndex,
      rowIndex: row.rowIndex,
      unit1: row.unit1, barcode1: row.barcode1, shopPrice1: row.shopPrice1, consumerPrice1: row.consumerPrice1,
      unit2: row.unit2, barcode2: row.barcode2, shopPrice2: row.shopPrice2, consumerPrice2: row.consumerPrice2,
      unit3: row.unit3, barcode3: row.barcode3, shopPrice3: row.shopPrice3, consumerPrice3: row.consumerPrice3,
      minPrice1: row.minPrice1,
      minPrice2: row.minPrice2,
      minPrice3: row.minPrice3,
    )).toList();
  }
}