// lib/logic/customers/customer_form_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'customers_state.dart';
import '../../data/repositories/customers_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/customer_model.dart';

class CustomerFormCubit extends Cubit<CustomerFormState> {
  final CustomersRepository _repository;
  final UserModel currentUser;

  CustomerFormCubit(this._repository, this.currentUser) : super(CustomerFormInitial());

  Future<void> saveCustomer({
    CustomerModel? customerToEdit,
    required String rawName, required String phone1, required String phone2,
    required String email, required String notes, required String region,
    required String district, required String street, required String gender,
    required double previousBalance, required String country, required String city,
    String? targetDelegateId,
    required String ownerSuffix, // استلام البادئة
  }) async {
    emit(CustomerFormLoading());
    try {
      if (customerToEdit == null) {
        await _repository.createCustomer(
          currentUser: currentUser, targetDelegateId: targetDelegateId ?? currentUser.id,
          rawName: rawName, phone1: phone1, phone2: phone2, email: email, notes: notes,
          region: region, district: district, street: street, gender: gender,
          previousBalance: previousBalance, country: country, city: city,
        );
      } else {
        final updated = customerToEdit.copyWith(
          phone1: phone1, phone2: phone2, email: email, notes: notes,
          region: region, district: district, street: street, gender: gender,
        );
        // نمرر البادئة (suffix) الحقيقية للمندوب عند التحديث بدلاً من الفراغ
        await _repository.updateCustomer(customer: updated, rawName: rawName, suffix: ownerSuffix);
      }
      emit(CustomerFormSuccess());
    } catch (e) {
      emit(CustomerFormError('حدث خطأ: $e'));
    }
  }
}