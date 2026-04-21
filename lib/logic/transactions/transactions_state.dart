// lib/logic/transactions/transactions_state.dart

import '../../data/models/unified_transaction.dart';

abstract class TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<UnifiedTransaction> transactions;
  TransactionsLoaded({required this.transactions});
}

class TransactionsError extends TransactionsState {
  final String message;
  TransactionsError(this.message);
}