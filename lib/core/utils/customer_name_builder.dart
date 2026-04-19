// lib/core/utils/customer_name_builder.dart

class CustomerNameBuilder {
  /// يقوم ببناء اسم الزبون بناءً على القاعدة المذكورة في الخطة
  /// {suffix} {name} - {region}
  /// مثال: suffix = "مول", name = "أبو أحمد", region = "الرياض" => "مول أبو أحمد - الرياض"
  static String build({
    required String suffix,
    required String name,
    required String region,
  }) {
    final cleanSuffix = suffix.trim();
    final cleanName = name.trim();
    final cleanRegion = region.trim();

    if (cleanSuffix.isEmpty) {
      return '$cleanName - $cleanRegion';
    }

    return '$cleanSuffix $cleanName - $cleanRegion';
  }
}