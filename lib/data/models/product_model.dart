// lib/data/models/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';

class ProductModel {
  final String id; final String itemCode; final String itemName;
  final String groupCode; final String currencyCode; final String defaultUnit;
  final bool isActive; final String tabName; final int columnIndex; final int rowIndex;

  final String unit1; final String barcode1; final double shopPrice1; final double consumerPrice1; final double minPrice1;
  final String unit2; final String barcode2; final double shopPrice2; final double consumerPrice2; final double minPrice2;
  final String unit3; final String barcode3; final double shopPrice3; final double consumerPrice3; final double minPrice3;

  ProductModel({
    required this.id, required this.itemCode, required this.itemName, required this.groupCode,
    required this.currencyCode, required this.defaultUnit, required this.isActive,
    required this.tabName, required this.columnIndex, required this.rowIndex,
    required this.unit1, required this.barcode1, required this.shopPrice1, required this.consumerPrice1, required this.minPrice1,
    required this.unit2, required this.barcode2, required this.shopPrice2, required this.consumerPrice2, required this.minPrice2,
    required this.unit3, required this.barcode3, required this.shopPrice3, required this.consumerPrice3, required this.minPrice3,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel(
      id: doc.id, itemCode: data[FirestoreKeys.itemCode] ?? '', itemName: data[FirestoreKeys.itemName] ?? '',
      groupCode: data[FirestoreKeys.groupCode] ?? '', currencyCode: data[FirestoreKeys.currencyCode] ?? '',
      defaultUnit: data[FirestoreKeys.defaultUnit] ?? '', isActive: data[FirestoreKeys.isActive] ?? true,
      tabName: data[FirestoreKeys.tabName] ?? '', columnIndex: data[FirestoreKeys.columnIndex] ?? 0, rowIndex: data[FirestoreKeys.rowIndex] ?? 0,
      unit1: data[FirestoreKeys.unit1] ?? '', barcode1: data[FirestoreKeys.barcode1] ?? '', shopPrice1: (data[FirestoreKeys.shopPrice1] ?? 0).toDouble(), consumerPrice1: (data[FirestoreKeys.consumerPrice1] ?? 0).toDouble(), minPrice1: (data[FirestoreKeys.minPrice1] ?? 0).toDouble(),
      unit2: data[FirestoreKeys.unit2] ?? '', barcode2: data[FirestoreKeys.barcode2] ?? '', shopPrice2: (data[FirestoreKeys.shopPrice2] ?? 0).toDouble(), consumerPrice2: (data[FirestoreKeys.consumerPrice2] ?? 0).toDouble(), minPrice2: (data[FirestoreKeys.minPrice2] ?? 0).toDouble(),
      unit3: data[FirestoreKeys.unit3] ?? '', barcode3: data[FirestoreKeys.barcode3] ?? '', shopPrice3: (data[FirestoreKeys.shopPrice3] ?? 0).toDouble(), consumerPrice3: (data[FirestoreKeys.consumerPrice3] ?? 0).toDouble(), minPrice3: (data[FirestoreKeys.minPrice3] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    FirestoreKeys.itemCode: itemCode, FirestoreKeys.itemName: itemName, FirestoreKeys.groupCode: groupCode,
    FirestoreKeys.currencyCode: currencyCode, FirestoreKeys.defaultUnit: defaultUnit, FirestoreKeys.isActive: isActive,
    FirestoreKeys.tabName: tabName, FirestoreKeys.columnIndex: columnIndex, FirestoreKeys.rowIndex: rowIndex,
    FirestoreKeys.unit1: unit1, FirestoreKeys.barcode1: barcode1, FirestoreKeys.shopPrice1: shopPrice1, FirestoreKeys.consumerPrice1: consumerPrice1, FirestoreKeys.minPrice1: minPrice1,
    FirestoreKeys.unit2: unit2, FirestoreKeys.barcode2: barcode2, FirestoreKeys.shopPrice2: shopPrice2, FirestoreKeys.consumerPrice2: consumerPrice2, FirestoreKeys.minPrice2: minPrice2,
    FirestoreKeys.unit3: unit3, FirestoreKeys.barcode3: barcode3, FirestoreKeys.shopPrice3: shopPrice3, FirestoreKeys.consumerPrice3: consumerPrice3, FirestoreKeys.minPrice3: minPrice3,
  };
}