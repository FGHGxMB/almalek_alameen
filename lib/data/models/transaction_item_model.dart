// lib/data/models/transaction_item_model.dart

import '../../core/constants/firestore_keys.dart';

class TransactionItemModel {
  final String productId; // The Document ID of the product
  final double quantity;
  final String unit;
  final double price;

  TransactionItemModel({
    required this.productId,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      productId: map[FirestoreKeys.productId] ?? '',
      quantity: (map[FirestoreKeys.quantity] ?? 0).toDouble(),
      unit: map[FirestoreKeys.unit] ?? '',
      price: (map[FirestoreKeys.price] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreKeys.productId: productId,
      FirestoreKeys.quantity: quantity,
      FirestoreKeys.unit: unit,
      FirestoreKeys.price: price,
    };
  }

  TransactionItemModel copyWith({
    String? productId,
    double? quantity,
    String? unit,
    double? price,
  }) {
    return TransactionItemModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
    );
  }
}