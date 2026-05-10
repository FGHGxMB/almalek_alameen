// lib/logic/transaction_details/transaction_details_state.dart

abstract class TransactionDetailsState {}

class TransactionDetailsLoading extends TransactionDetailsState {}

class TransactionDetailsLoaded extends TransactionDetailsState {
  final Map<String, String> productNames; // خريطة لربط id باسم المادة
  TransactionDetailsLoaded(this.productNames);
}