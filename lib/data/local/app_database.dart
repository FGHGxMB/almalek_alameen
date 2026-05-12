// lib/data/local/app_database.dart

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

// هذا الملف سيتم توليده تلقائياً عبر الأوامر لاحقاً
part 'app_database.g.dart';

class ProductsTable extends Table {
  TextColumn get id => text()(); // Document ID
  TextColumn get itemCode => text()();
  TextColumn get itemName => text()();
  TextColumn get groupCode => text()();
  TextColumn get currencyCode => text()();
  TextColumn get defaultUnit => text()();
  BoolColumn get isActive => boolean()();
  TextColumn get tabName => text()();
  IntColumn get columnIndex => integer()();
  IntColumn get rowIndex => integer()();

  TextColumn get unit1 => text()();
  TextColumn get barcode1 => text()();
  RealColumn get shopPrice1 => real()();
  RealColumn get consumerPrice1 => real()();

  TextColumn get unit2 => text()();
  TextColumn get barcode2 => text()();
  RealColumn get shopPrice2 => real()();
  RealColumn get consumerPrice2 => real()();

  TextColumn get unit3 => text()();
  TextColumn get barcode3 => text()();
  RealColumn get shopPrice3 => real()();
  RealColumn get consumerPrice3 => real()();

  RealColumn get minPrice1 => real().withDefault(const Constant(0.0))();
  RealColumn get minPrice2 => real().withDefault(const Constant(0.0))();
  RealColumn get minPrice3 => real().withDefault(const Constant(0.0))();

  RealColumn get costPrice1 => real().withDefault(const Constant(0.0))();
  RealColumn get costPrice2 => real().withDefault(const Constant(0.0))();
  RealColumn get costPrice3 => real().withDefault(const Constant(0.0))();

  TextColumn get currency1 => text().withDefault(const Constant('USD'))();
  TextColumn get currency2 => text().withDefault(const Constant('USD'))();
  TextColumn get currency3 => text().withDefault(const Constant('USD'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables:[ProductsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // استبدال المواد بالكامل (مسح القديم وإدخال الجديد دفعة واحدة)
  Future<void> replaceAllProducts(List<ProductsTableCompanion> products) async {
    await transaction(() async {
      await delete(productsTable).go();
      await batch((batch) {
        batch.insertAll(productsTable, products);
      });
    });
  }

  // جلب المواد النشطة فقط
  Future<List<ProductsTableData>> getAllActiveProducts() async {
    return (select(productsTable)..where((t) => t.isActive.equals(true))).get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spice_app_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}