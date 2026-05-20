// lib/core/services/printer_service.dart

import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterService {
  // استخدام Singleton لضمان عدم تضارب الاتصالات في الخلفية
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  // الدالة السحرية للطباعة مع الاتصال التلقائي الصامت
  Future<void> printImage(Uint8List imageBytes) async {
    bool? isConnected = await bluetooth.isConnected;

    // 1. إذا لم تكن الطابعة متصلة، نحاول الاتصال بها تلقائياً
    if (isConnected != true) {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();

      if (devices.isEmpty) {
        throw Exception('لا توجد طابعات مقترنة! يرجى الذهاب لإعدادات البلوتوث في الهاتف واقتران الطابعة أولاً.');
      }

      // جلب عنوان الطابعة المحفوظ (إن وجدنا إعداداً له لاحقاً)، وإلا نتصل بأول طابعة مقترنة
      final prefs = await SharedPreferences.getInstance();
      final savedMac = prefs.getString('saved_printer_mac');

      BluetoothDevice? targetDevice;
      if (savedMac != null) {
        try {
          targetDevice = devices.firstWhere((d) => d.address == savedMac);
        } catch(e) {
          targetDevice = devices.first; // احتياطاً نأخذ الأولى
        }
      } else {
        // في العادة المندوب يقترن بطابعة واحدة فقط (طابعته الحرارية)، فنأخذها مباشرة
        targetDevice = devices.first;
      }

      // محاولة الاتصال بالطابعة
      try {
        await bluetooth.connect(targetDevice);
      } catch (e) {
        throw Exception('تعذر الاتصال بالطابعة (${targetDevice.name}). تأكد أنها قيد التشغيل وقريبة منك.');
      }
    }

    // 2. الطابعة الآن متصلة بالتأكيد، نرسل الصورة
    try {
      await bluetooth.printImageBytes(imageBytes);
      // مسافات فارغة لرفع الورقة لكي يستطيع المندوب قطعها بسهولة
      await bluetooth.printNewLine();
      await bluetooth.printNewLine();
      await bluetooth.printNewLine();
    } catch (e) {
      throw Exception('حدث خطأ أثناء إرسال البيانات للطابعة: $e');
    }
  }

  // قطع الاتصال (مفيدة إذا أردنا توفير بطارية الطابعة، لكن تركها متصلة أفضل للسرعة)
  Future<void> disconnect() async {
    await bluetooth.disconnect();
  }
}