// lib/core/utils/account_code_generator.dart

class AccountCodeGenerator {
  /// يقوم بدمج بادئة حساب الزبائن للمندوب مع العداد لتوليد رمز فريد
  /// مثال: mainAccount = "102", counter = 15 => "10215"
  static String generate(String mainAccount, int counter) {
    return '$mainAccount$counter';
  }
}