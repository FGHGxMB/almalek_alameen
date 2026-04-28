// lib/logic/customers/customers_cubit.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'customers_state.dart';
import '../../data/repositories/customers_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/customer_model.dart';
import '../../core/utils/excel_exporter.dart';
import '../../data/local/filters_storage.dart';
import '../../core/constants/firestore_keys.dart';

class CustomerFilters {
  CustomerFilters();
  String sortMode = 'last_transaction';
  bool sortByRegion = false;
  bool sortByDelegate = false;
  List<String> selectedDelegates = [];
  List<String> selectedRegions =[];
  double? minBalance;
  double? maxBalance;
  String? gender;
  String? balanceState;

  Map<String, dynamic> toJson() => {
    'sortMode': sortMode, 'sortByRegion': sortByRegion, 'sortByDelegate': sortByDelegate,
    'selectedDelegates': selectedDelegates, 'selectedRegions': selectedRegions,
    'minBalance': minBalance, 'maxBalance': maxBalance, 'gender': gender, 'balanceState': balanceState,
  };

  factory CustomerFilters.fromJson(Map<String, dynamic> json) {
    final filters = CustomerFilters();
    filters.sortMode = json['sortMode'] ?? 'last_transaction';
    filters.sortByRegion = json['sortByRegion'] ?? false;
    filters.sortByDelegate = json['sortByDelegate'] ?? false;
    filters.selectedDelegates = List<String>.from(json['selectedDelegates'] ??[]);
    filters.selectedRegions = List<String>.from(json['selectedRegions'] ??[]);
    filters.minBalance = json['minBalance'];
    filters.maxBalance = json['maxBalance'];
    filters.gender = json['gender'];
    filters.balanceState = json['balanceState'];
    return filters;
  }
}

class CustomersCubit extends Cubit<CustomersState> {
  final CustomersRepository _repository;
  final UserModel currentUser;
  StreamSubscription? _sub;

  List<CustomerModel> _allCustomers =[];
  CustomerFilters filters = CustomerFilters();
  Set<String> selectedIds = {};
  bool isSelectionMode = false;

  // خريطة لتخزين بيانات المندوبين (الاسم واللون)
  Map<String, UserModel> usersMap = {};

  bool get hasActiveFilters =>
      filters.sortMode != 'last_transaction' || filters.sortByRegion || filters.sortByDelegate ||
          filters.selectedRegions.isNotEmpty || filters.minBalance != null || filters.maxBalance != null ||
          filters.gender != null || filters.balanceState != null || (filters.selectedDelegates.length > 1);

  CustomersCubit(this._repository, this.currentUser) : super(CustomersLoading()) {
    _initCubit();
  }

  Future<void> _initCubit() async {
    // جلب بيانات المندوبين المراقبين لعرض أسمائهم وألوانهم
    final delegateIds = [currentUser.id, ...currentUser.canMonitor];
    final usersSnap = await FirebaseFirestore.instance.collection(FirestoreKeys.users).where(FieldPath.documentId, whereIn: delegateIds).get();
    for (var doc in usersSnap.docs) {
      usersMap[doc.id] = UserModel.fromFirestore(doc);
    }

    final savedFilters = await FiltersStorage.getCustomerFilters();
    if (savedFilters != null) {
      filters = savedFilters;
    } else {
      filters.selectedDelegates = [currentUser.id];
    }

    _sub = _repository.getCustomersStream(currentUser).listen((customers) {
      _allCustomers = customers;
      applyFilters();
    }, onError: (e) => emit(CustomersError('خطأ: $e')));
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) selectedIds.remove(id);
    else selectedIds.add(id);
    if (selectedIds.isEmpty) isSelectionMode = false;
    applyFilters();
  }

  void toggleSelectionMode(String initialId) {
    isSelectionMode = true;
    selectedIds.add(initialId);
    applyFilters();
  }

  void selectAll(List<CustomerModel> visibleList) {
    if (selectedIds.length == visibleList.length) {
      selectedIds.clear();
      isSelectionMode = false;
    } else {
      selectedIds = visibleList.map((c) => c.id).toSet();
    }
    applyFilters();
  }

  Future<void> deleteCustomer(String id) async {
    try {
      final hasTrans = await _repository.hasTransactions(id);
      if (hasTrans) {
        emit(CustomersError('لا يمكن حذف الزبون لوجود حركات مالية (فواتير/سندات) مرتبطة به!'));
        applyFilters(); // لإرجاع الحالة لـ Loaded
        return;
      }
      await _repository.deleteCustomer(id);
    } catch(e) {
      emit(CustomersError(e.toString()));
      applyFilters();
    }
  }

  void applyFilters() {
    List<CustomerModel> filtered = List.from(_allCustomers);

    filtered = filtered.where((c) {
      if (filters.selectedDelegates.isNotEmpty && !filters.selectedDelegates.contains(c.delegateId)) return false;
      if (filters.selectedRegions.isNotEmpty && !filters.selectedRegions.contains(c.region)) return false;
      if (filters.minBalance != null && c.balance <= filters.minBalance!) return false;
      if (filters.maxBalance != null && c.balance >= filters.maxBalance!) return false;
      if (filters.gender != null && c.gender != filters.gender) return false;
      if (filters.balanceState == 'has_debt' && c.balance <= 0) return false;
      if (filters.balanceState == 'zero' && c.balance != 0) return false;
      if (filters.balanceState == 'creditor' && c.balance >= 0) return false;
      return true;
    }).toList();

    filtered.sort((a, b) {
      int result = 0;
      if (filters.sortByDelegate) {
        result = a.delegateId.compareTo(b.delegateId);
        if (result != 0) return result;
      }
      if (filters.sortByRegion) {
        result = a.region.compareTo(b.region);
        if (result != 0) return result;
      }
      if (filters.sortMode == 'balance_desc') result = b.balance.compareTo(a.balance);
      else if (filters.sortMode == 'balance_asc') result = a.balance.compareTo(b.balance);
      else result = b.lastTransactionDate.compareTo(a.lastTransactionDate);
      return result;
    });

    emit(CustomersLoaded(filtered));
  }

  void updateFilters(CustomerFilters newFilters) {
    filters = newFilters;
    FiltersStorage.saveCustomerFilters(filters);
    applyFilters();
  }

  void resetFilters() {
    filters = CustomerFilters();
    filters.selectedDelegates = [currentUser.id];
    FiltersStorage.saveCustomerFilters(filters);
    applyFilters();
  }

  Future<void> exportDataToExcel() async {
    final currentState = state;
    if (currentState is CustomersLoaded) {
      try {
        // إذا كان هناك تحديد، استخرج المحدد فقط، وإلا استخرج القائمة المعروضة
        final toExport = selectedIds.isNotEmpty
            ? currentState.customers.where((c) => selectedIds.contains(c.id)).toList()
            : currentState.customers;

        await ExcelExporter.exportCustomers(toExport);
      } catch (e) {
        emit(CustomersError('فشل التصدير: $e'));
        applyFilters();
      }
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}