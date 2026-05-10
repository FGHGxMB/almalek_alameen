// lib/data/local/transactions_filters_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../logic/transactions/transactions_cubit.dart';

class TransactionsFiltersStorage {
  static const String _key = 'transactions_filters_prefs';

  static Future<void> saveFilters(TransactionFilters filters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(filters.toJson()));
  }

  static Future<TransactionFilters?> getFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str != null) {
      try { return TransactionFilters.fromJson(jsonDecode(str)); } catch (e) { return null; }
    }
    return null;
  }
}