// lib/data/models/product_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';

class ProductModel {
  final String id;
  final String itemCode;
  final String itemName;
  final String groupCode;
  final String currencyCode;
  final String defaultUnit;
  final bool isActive;
  final String tabName;
  final int columnIndex;
  final int rowIndex;

  // الوحدات
  final String unit1; final String barcode1; final double shopPrice1; final double consumerPrice1;
  final String unit2; final String barcode2; final double shopPrice2; final double consumerPrice2;
  final String unit3; final String barcode3; final double shopPrice3; final double consumerPrice3;

  ProductModel({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.groupCode,
    required this.currencyCode,
    required this.defaultUnit,
    required this.isActive,
    required this.tabName,
    required this.columnIndex,
    required this.rowIndex,
    required this.unit1, required this.barcode1, required this.shopPrice1, required this.consumerPrice1,
    required this.unit2, required this.barcode2, required this.shopPrice2, required this.consumerPrice2,
    required this.unit3, required this.barcode3, required this.shopPrice3, required this.consumerPrice3,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel(
      id: doc.id,
      itemCode: data[FirestoreKeys.itemCode] ?? '',
      itemName: data[FirestoreKeys.itemName] ?? '',
      groupCode: data[FirestoreKeys.groupCode] ?? '',
      currencyCode: data[FirestoreKeys.currencyCode] ?? '',
      defaultUnit: data[FirestoreKeys.defaultUnit] ?? '',
      isActive: data[FirestoreKeys.isActive] ?? true,
      tabName: data[FirestoreKeys.tabName] ?? '',
      columnIndex: data[FirestoreKeys.columnIndex] ?? 0,
      rowIndex: data[FirestoreKeys.rowIndex] ?? 0,
      unit1: data[FirestoreKeys.unit1] ?? '', barcode1: data[FirestoreKeys.barcode1] ?? '', shopPrice1: (data[FirestoreKeys.shopPrice1] ?? 0).toDouble(), consumerPrice1: (data[FirestoreKeys.consumerPrice1] ?? 0).toDouble(),
      unit2: data[FirestoreKeys.unit2] ?? '', barcode2: data[FirestoreKeys.barcode2] ?? '', shopPrice2: (data[FirestoreKeys.shopPrice2] ?? 0).toDouble(), consumerPrice2: (data[FirestoreKeys.consumerPrice2] ?? 0).toDouble(),
      unit3: data[FirestoreKeys.unit3] ?? '', barcode3: data[FirestoreKeys.barcode3] ?? '', shopPrice3: (data[FirestoreKeys.shopPrice3] ?? 0).toDouble(), consumerPrice3: (data[FirestoreKeys.consumerPrice3] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreKeys.itemCode: itemCode,
      FirestoreKeys.itemName: itemName,
      FirestoreKeys.groupCode: groupCode,
      FirestoreKeys.currencyCode: currencyCode,
      FirestoreKeys.defaultUnit: defaultUnit,
      FirestoreKeys.isActive: isActive,
      FirestoreKeys.tabName: tabName,
      FirestoreKeys.columnIndex: columnIndex,
      FirestoreKeys.rowIndex: rowIndex,
      FirestoreKeys.unit1: unit1, FirestoreKeys.barcode1: barcode1, FirestoreKeys.shopPrice1: shopPrice1, FirestoreKeys.consumerPrice1: consumerPrice1,
      FirestoreKeys.unit2: unit2, FirestoreKeys.barcode2: barcode2, FirestoreKeys.shopPrice2: shopPrice2, FirestoreKeys.consumerPrice2: consumerPrice2,
      FirestoreKeys.unit3: unit3, FirestoreKeys.barcode3: barcode3, FirestoreKeys.shopPrice3: shopPrice3, FirestoreKeys.consumerPrice3: consumerPrice3,
    };
  }

  ProductModel copyWith({
    String? id, String? itemCode, String? itemName, String? groupCode, String? currencyCode,
    String? defaultUnit, bool? isActive, String? tabName, int? columnIndex, int? rowIndex,
    String? unit1, String? barcode1, double? shopPrice1, double? consumerPrice1,
    String? unit2, String? barcode2, double? shopPrice2, double? consumerPrice2,
    String? unit3, String? barcode3, double? shopPrice3, double? consumerPrice3,
  }) {
    return ProductModel(
      id: id ?? this.id, itemCode: itemCode ?? this.itemCode, itemName: itemName ?? this.itemName,
      groupCode: groupCode ?? this.groupCode, currencyCode: currencyCode ?? this.currencyCode,
      defaultUnit: defaultUnit ?? this.defaultUnit, isActive: isActive ?? this.isActive,
      tabName: tabName ?? this.tabName, columnIndex: columnIndex ?? this.columnIndex, rowIndex: rowIndex ?? this.rowIndex,
      unit1: unit1 ?? this.unit1, barcode1: barcode1 ?? this.barcode1, shopPrice1: shopPrice1 ?? this.shopPrice1, consumerPrice1: consumerPrice1 ?? this.consumerPrice1,
      unit2: unit2 ?? this.unit2, barcode2: barcode2 ?? this.barcode2, shopPrice2: shopPrice2 ?? this.shopPrice2, consumerPrice2: consumerPrice2 ?? this.consumerPrice2,
      unit3: unit3 ?? this.unit3, barcode3: barcode3 ?? this.barcode3, shopPrice3: shopPrice3 ?? this.shopPrice3, consumerPrice3: consumerPrice3 ?? this.consumerPrice3,
    );
  }
}