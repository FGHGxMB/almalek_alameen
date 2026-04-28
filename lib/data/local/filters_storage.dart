// lib/data/local/filters_storage.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../logic/customers/customers_cubit.dart';

class FiltersStorage {
  static const String _customersFilterKey = 'customers_filters_prefs';

  // حفظ الفلاتر في ذاكرة الهاتف
  static Future<void> saveCustomerFilters(CustomerFilters filters) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(filters.toJson());
    await prefs.setString(_customersFilterKey, jsonString);
  }

  // استرجاع الفلاتر
  static Future<CustomerFilters?> getCustomerFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_customersFilterKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return CustomerFilters.fromJson(jsonMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}