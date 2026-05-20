// lib/data/models/cost_material_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CostMaterialModel {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String tabName;
  final int columnIndex;
  final int rowIndex;
  final bool isSynced;

  CostMaterialModel({
    required this.id, required this.name, required this.price, required this.currency,
    required this.tabName, required this.columnIndex, required this.rowIndex, this.isSynced = true,
  });

  factory CostMaterialModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CostMaterialModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'SYP',
      tabName: data['tab_name'] ?? 'عام',
      columnIndex: data['column_index'] ?? 0,
      rowIndex: data['row_index'] ?? 0,
      isSynced: !doc.metadata.hasPendingWrites,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name, 'price': price, 'currency': currency,
    'tab_name': tabName, 'column_index': columnIndex, 'row_index': rowIndex,
    'updated_at': FieldValue.serverTimestamp(),
  };

  CostMaterialModel copyWith({String? id, String? name, double? price, String? currency, String? tabName, int? columnIndex, int? rowIndex}) {
    return CostMaterialModel(
      id: id ?? this.id, name: name ?? this.name, price: price ?? this.price, currency: currency ?? this.currency,
      tabName: tabName ?? this.tabName, columnIndex: columnIndex ?? this.columnIndex, rowIndex: rowIndex ?? this.rowIndex,
    );
  }
}