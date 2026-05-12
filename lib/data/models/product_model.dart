// lib/data/models/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';

class ProductModel {
  final String id; final String itemCode; final String itemName;
  final String groupCode; final String currencyCode; final String defaultUnit;
  final bool isActive; final String tabName; final int columnIndex; final int rowIndex;

  final String unit1; final String barcode1; final double shopPrice1; final double consumerPrice1; final double minPrice1; final double costPrice1; final String currency1;
  final String unit2; final String barcode2; final double shopPrice2; final double consumerPrice2; final double minPrice2; final double costPrice2; final String currency2;
  final String unit3; final String barcode3; final double shopPrice3; final double consumerPrice3; final double minPrice3; final double costPrice3; final String currency3;

  final bool isSynced;

  ProductModel({
    required this.id, required this.itemCode, required this.itemName, required this.groupCode,
    required this.currencyCode, required this.defaultUnit, required this.isActive,
    required this.tabName, required this.columnIndex, required this.rowIndex,
    required this.unit1, required this.barcode1, required this.shopPrice1, required this.consumerPrice1, required this.minPrice1, required this.costPrice1, required this.currency1,
    required this.unit2, required this.barcode2, required this.shopPrice2, required this.consumerPrice2, required this.minPrice2, required this.costPrice2, required this.currency2,
    required this.unit3, required this.barcode3, required this.shopPrice3, required this.consumerPrice3, required this.minPrice3, required this.costPrice3, required this.currency3,
    this.isSynced = true,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel(
      id: doc.id, itemCode: data[FirestoreKeys.itemCode] ?? '', itemName: data[FirestoreKeys.itemName] ?? '',
      groupCode: data[FirestoreKeys.groupCode] ?? '', currencyCode: data[FirestoreKeys.currencyCode] ?? '',
      defaultUnit: data[FirestoreKeys.defaultUnit] ?? '', isActive: data[FirestoreKeys.isActive] ?? true,
      tabName: data[FirestoreKeys.tabName] ?? '', columnIndex: data[FirestoreKeys.columnIndex] ?? 0, rowIndex: data[FirestoreKeys.rowIndex] ?? 0,

      unit1: data[FirestoreKeys.unit1] ?? '', barcode1: data[FirestoreKeys.barcode1] ?? '', shopPrice1: (data[FirestoreKeys.shopPrice1] ?? 0).toDouble(), consumerPrice1: (data[FirestoreKeys.consumerPrice1] ?? 0).toDouble(), minPrice1: (data[FirestoreKeys.minPrice1] ?? 0).toDouble(), costPrice1: (data[FirestoreKeys.costPrice1] ?? 0).toDouble(), currency1: data[FirestoreKeys.currency1] ?? 'USD',
      unit2: data[FirestoreKeys.unit2] ?? '', barcode2: data[FirestoreKeys.barcode2] ?? '', shopPrice2: (data[FirestoreKeys.shopPrice2] ?? 0).toDouble(), consumerPrice2: (data[FirestoreKeys.consumerPrice2] ?? 0).toDouble(), minPrice2: (data[FirestoreKeys.minPrice2] ?? 0).toDouble(), costPrice2: (data[FirestoreKeys.costPrice2] ?? 0).toDouble(), currency2: data[FirestoreKeys.currency2] ?? 'USD',
      unit3: data[FirestoreKeys.unit3] ?? '', barcode3: data[FirestoreKeys.barcode3] ?? '', shopPrice3: (data[FirestoreKeys.shopPrice3] ?? 0).toDouble(), consumerPrice3: (data[FirestoreKeys.consumerPrice3] ?? 0).toDouble(), minPrice3: (data[FirestoreKeys.minPrice3] ?? 0).toDouble(), costPrice3: (data[FirestoreKeys.costPrice3] ?? 0).toDouble(), currency3: data[FirestoreKeys.currency3] ?? 'USD',
      isSynced: !doc.metadata.hasPendingWrites,
    );
  }

  Map<String, dynamic> toFirestore() => {
    FirestoreKeys.itemCode: itemCode, FirestoreKeys.itemName: itemName, FirestoreKeys.groupCode: groupCode,
    FirestoreKeys.currencyCode: currencyCode, FirestoreKeys.defaultUnit: defaultUnit, FirestoreKeys.isActive: isActive,
    FirestoreKeys.tabName: tabName, FirestoreKeys.columnIndex: columnIndex, FirestoreKeys.rowIndex: rowIndex,

    FirestoreKeys.unit1: unit1, FirestoreKeys.barcode1: barcode1, FirestoreKeys.shopPrice1: shopPrice1, FirestoreKeys.consumerPrice1: consumerPrice1, FirestoreKeys.minPrice1: minPrice1, FirestoreKeys.costPrice1: costPrice1, FirestoreKeys.currency1: currency1,
    FirestoreKeys.unit2: unit2, FirestoreKeys.barcode2: barcode2, FirestoreKeys.shopPrice2: shopPrice2, FirestoreKeys.consumerPrice2: consumerPrice2, FirestoreKeys.minPrice2: minPrice2, FirestoreKeys.costPrice2: costPrice2, FirestoreKeys.currency2: currency2,
    FirestoreKeys.unit3: unit3, FirestoreKeys.barcode3: barcode3, FirestoreKeys.shopPrice3: shopPrice3, FirestoreKeys.consumerPrice3: consumerPrice3, FirestoreKeys.minPrice3: minPrice3, FirestoreKeys.costPrice3: costPrice3, FirestoreKeys.currency3: currency3,
  };

  ProductModel copyWith({
    String? id, String? itemCode, String? itemName, String? groupCode,
    String? currencyCode, String? defaultUnit, bool? isActive,
    String? tabName, int? columnIndex, int? rowIndex,
    String? unit1, String? barcode1, double? shopPrice1, double? consumerPrice1, double? minPrice1, double? costPrice1, String? currency1,
    String? unit2, String? barcode2, double? shopPrice2, double? consumerPrice2, double? minPrice2, double? costPrice2, String? currency2,
    String? unit3, String? barcode3, double? shopPrice3, double? consumerPrice3, double? minPrice3, double? costPrice3, String? currency3,
    bool? isSynced,
  }) {
    return ProductModel(
      id: id ?? this.id, itemCode: itemCode ?? this.itemCode, itemName: itemName ?? this.itemName,
      groupCode: groupCode ?? this.groupCode, currencyCode: currencyCode ?? this.currencyCode,
      defaultUnit: defaultUnit ?? this.defaultUnit, isActive: isActive ?? this.isActive,
      tabName: tabName ?? this.tabName, columnIndex: columnIndex ?? this.columnIndex, rowIndex: rowIndex ?? this.rowIndex,

      unit1: unit1 ?? this.unit1, barcode1: barcode1 ?? this.barcode1, shopPrice1: shopPrice1 ?? this.shopPrice1, consumerPrice1: consumerPrice1 ?? this.consumerPrice1, minPrice1: minPrice1 ?? this.minPrice1, costPrice1: costPrice1 ?? this.costPrice1, currency1: currency1 ?? this.currency1,
      unit2: unit2 ?? this.unit2, barcode2: barcode2 ?? this.barcode2, shopPrice2: shopPrice2 ?? this.shopPrice2, consumerPrice2: consumerPrice2 ?? this.consumerPrice2, minPrice2: minPrice2 ?? this.minPrice2, costPrice2: costPrice2 ?? this.costPrice2, currency2: currency2 ?? this.currency2,
      unit3: unit3 ?? this.unit3, barcode3: barcode3 ?? this.barcode3, shopPrice3: shopPrice3 ?? this.shopPrice3, consumerPrice3: consumerPrice3 ?? this.consumerPrice3, minPrice3: minPrice3 ?? this.minPrice3, costPrice3: costPrice3 ?? this.costPrice3, currency3: currency3 ?? this.currency3,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}