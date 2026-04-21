// lib/core/services/printer_service.dart

import 'dart:io';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';
import '../../data/models/unified_transaction.dart';

class PrinterService {
  // عنوان الـ IP الافتراضي لطابعات Rongta يكون عادة 192.168.1.100 أو 192.168.0.100
  // في المشاريع الحقيقية يتم حفظه في SharedPreferences ليتغير حسب الطابعة
  final String printerIp;
  final int port;

  PrinterService({this.printerIp = '192.168.1.100', this.port = 9100});

  Future<void> printTransaction(UnifiedTransaction transaction) async {
    try {
      final profile = await CapabilityProfile.load();
      // طابعات المندوبين المحمولة RPP300 عادة تكون مقاس 58mm
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes =[];

      // --- ترويسة الفاتورة ---
      bytes += generator.text('AL-MALEK AL-AMEEN',
          styles: const PosStyles(align: PosAlign.center, bold: true, width: PosTextSize.size2, height: PosTextSize.size2));
      bytes += generator.text('Spice Distribution Co.',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.emptyLines(1);

      // --- نوع المعاملة ---
      String typeLabel = '';
      if (transaction.type == TransactionType.invoice) typeLabel = 'SALES INVOICE';
      else if (transaction.type == TransactionType.returnDoc) typeLabel = 'RETURN INVOICE';
      else typeLabel = 'RECEIPT';

      bytes += generator.text(typeLabel, styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text('No: ${transaction.localNumber}', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(transaction.date)}', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.emptyLines(1);

      // --- معلومات الزبون ---
      bytes += generator.text('Customer:', styles: const PosStyles(bold: true));
      // ملاحظة: اللغة العربية قد تحتاج إعدادات إضافية (CodePage) في الطابعة
      bytes += generator.text(transaction.customerName, styles: const PosStyles(align: PosAlign.right));
      bytes += generator.hr();

      // --- تفاصيل المعاملة ---
      bytes += generator.text('Total Amount:', styles: const PosStyles(bold: true));
      bytes += generator.text(
        NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2).format(transaction.amount),
        styles: const PosStyles(align: PosAlign.right, bold: true, width: PosTextSize.size2, height: PosTextSize.size2),
      );

      bytes += generator.emptyLines(1);
      bytes += generator.hr();
      bytes += generator.text('Thank you!', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.emptyLines(3);
      bytes += generator.cut(); // قص الورقة

      // --- الاتصال بالطابعة وإرسال الأوامر ---
      final socket = await Socket.connect(printerIp, port, timeout: const Duration(seconds: 5));
      socket.add(bytes);
      await socket.flush();
      await socket.close();

    } catch (e) {
      throw Exception('تعذر الاتصال بالطابعة، تأكد من تشغيلها واتصال الهاتف بنفس شبكة WiFi الخاصة بها. ($e)');
    }
  }
}