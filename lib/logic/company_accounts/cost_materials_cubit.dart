// lib/logic/company_accounts/cost_materials_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/company_accounts_repository.dart';
import '../../data/models/cost_material_model.dart';

abstract class CostMaterialsState {}
class CMInitial extends CostMaterialsState {}
class CMLoaded extends CostMaterialsState {
  final List<CostMaterialModel> materials;
  CMLoaded(this.materials);
}

class CostMaterialsCubit extends Cubit<CostMaterialsState> {
  final CompanyAccountsRepository _repo;
  StreamSubscription? _sub;

  CostMaterialsCubit(this._repo) : super(CMInitial()) {
    _sub = _repo.getCostMaterialsStream().listen((data) => emit(CMLoaded(data)));
  }

  void saveMaterial(CostMaterialModel m, bool isNew) => _repo.saveCostMaterial(m, isNew: isNew);
  void deleteMaterial(String id) => _repo.deleteCostMaterial(id);
  void moveMaterial(String id, String tab, int col, int row) => _repo.moveCostMaterial(id, tab, col, row);

  @override
  Future<void> close() { _sub?.cancel(); return super.close(); }
}