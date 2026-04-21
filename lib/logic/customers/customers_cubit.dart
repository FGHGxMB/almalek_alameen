// lib/logic/customers/customers_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'customers_state.dart';
import '../../data/repositories/customers_repository.dart';
import '../../data/models/user_model.dart';
import '../../core/utils/excel_exporter.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomersRepository _repository;
  final UserModel currentUser;
  StreamSubscription? _sub;

  CustomersCubit(this._repository, this.currentUser) : super(CustomersLoading()) {
    _sub = _repository.getCustomersStream(currentUser).listen(
          (customers) => emit(CustomersLoaded(customers)),
      onError: (e) => emit(CustomersError('خطأ: $e')),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  Future<void> exportDataToExcel() async {
    final currentState = state;
    if (currentState is CustomersLoaded) {
      try {
        await ExcelExporter.exportCustomers(currentState.customers);
      } catch (e) {
        emit(CustomersError('فشل التصدير: $e'));
      }
    }
  }
}