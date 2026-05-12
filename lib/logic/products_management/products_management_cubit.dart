// lib/logic/products_management/products_management_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/products_repository.dart';
import '../../data/models/product_model.dart';

abstract class ProductsManagementState {}
class PMInitial extends ProductsManagementState {}
class PMLoaded extends ProductsManagementState {
  final List<ProductModel> products;
  PMLoaded(this.products);
}
class PMError extends ProductsManagementState { final String message; PMError(this.message); }
class PMSuccess extends ProductsManagementState { final String message; PMSuccess(this.message); }

class ProductsManagementCubit extends Cubit<ProductsManagementState> {
  final ProductsRepository _repo;
  StreamSubscription? _sub;

  ProductsManagementCubit(this._repo) : super(PMInitial()) {
    _sub = _repo.getAdminProductsStream().listen((data) => emit(PMLoaded(data)));
  }

  void moveProduct(String id, String newTab, int newCol, int newRow) {
    _repo.moveProduct(id, newTab, newCol, newRow);
  }

  @override
  Future<void> close() { _sub?.cancel(); return super.close(); }

  Future<void> deleteProduct(String id) async {
    try {
      await _repo.deleteProduct(id);
      // بعد الحذف لا حاجة لاستدعاء شيء لأن الـ Stream سيحدث القائمة
      emit(PMSuccess('تم حذف المادة نهائياً'));
    } catch (e) {
      emit(PMError(e.toString()));
    }
  }

  Future<String?> checkProductUsage(String id) async {
    return await _repo.checkProductUsage(id);
  }
}