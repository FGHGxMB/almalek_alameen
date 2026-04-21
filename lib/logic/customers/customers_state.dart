// lib/logic/customers/customers_state.dart
import '../../data/models/customer_model.dart';

abstract class CustomersState {}
class CustomersLoading extends CustomersState {}
class CustomersLoaded extends CustomersState {
  final List<CustomerModel> customers;
  CustomersLoaded(this.customers);
}
class CustomersError extends CustomersState {
  final String message;
  CustomersError(this.message);
}

abstract class CustomerFormState {}
class CustomerFormInitial extends CustomerFormState {}
class CustomerFormLoading extends CustomerFormState {}
class CustomerFormSuccess extends CustomerFormState {}
class CustomerFormError extends CustomerFormState {
  final String message;
  CustomerFormError(this.message);
}