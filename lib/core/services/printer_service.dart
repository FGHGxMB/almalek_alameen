// lib/core/services/printer_service.dart

import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterService {
  // استخدام Singleton لضمان اتصال واحد فقط
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  // جلب الأجهزة المقترنة (لنعرضها للمستخدم ليختار طابعته لاحقاً)
  Future<List<BluetoothDevice>> getPairedDevices() async {
    return await bluetooth.getBondedDevices();
  }

  // الاتصال بالطابعة
  Future<void> connect(BluetoothDevice device) async {
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected != true) {
      await bluetooth.connect(device);
    }
  }

  // قطع الاتصال
  Future<void> disconnect() async {
    await bluetooth.disconnect();
  }

  // الدالة السحرية: تستقبل بايتات الصورة وتطبعها
  Future<void> printImage(Uint8List imageBytes) async {
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected != true) {
      throw Exception('الطابعة غير متصلة! يرجى اختيار طابعة من إعدادات البلوتوث.');
    }

    // طباعة الصورة
    await bluetooth.printImageBytes(imageBytes);
    // مسافات فارغة لرفع الورقة لكي يستطيع المندوب قطعها
    await bluetooth.printNewLine();
    await bluetooth.printNewLine();
    await bluetooth.printNewLine();
  }
}