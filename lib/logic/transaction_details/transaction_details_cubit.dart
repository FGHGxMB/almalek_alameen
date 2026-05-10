// lib/logic/transaction_details/transaction_details_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_details_state.dart';
import '../../data/repositories/products_repository.dart';

class TransactionDetailsCubit extends Cubit<TransactionDetailsState> {
  final ProductsRepository _productsRepo;

  TransactionDetailsCubit(this._productsRepo) : super(TransactionDetailsLoading());

  Future<void> loadDetails() async {
    try {
      final products = await _productsRepo.getLocalProducts();
      final Map<String, String> namesMap = {};
      for (var p in products) {
        namesMap[p.id] = p.itemName;
      }
      emit(TransactionDetailsLoaded(namesMap));
    } catch (e) {
      // حتى في حال الخطأ نعرض خريطة فارغة لكي تعمل الشاشة
      emit(TransactionDetailsLoaded({}));
    }
  }
}