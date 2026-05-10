// lib/core/utils/excel_exporter.dart

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/return_model.dart';
import '../../data/models/receipt_model.dart';
import '../../data/models/customer_model.dart';

class ExcelExporter {
  // 1. تصدير المعاملات (فواتير، مرتجعات، سندات) في ملف واحد
  static Future<void> exportTransactions({
    required List<InvoiceModel> invoices,
    required List<ReturnModel> returns,
    required List<ReceiptModel> receipts,
  }) async {
    var excel = Excel.createExcel();

    // إنشاء الشيتات مباشرة بدون حذف أو تعديل الافتراضي لتجنب خطأ الحزمة
    Sheet invoiceSheet = excel['فواتير المبيعات'];
    _appendRow(invoiceSheet, 0,[
      'رقم الفاتورة', 'رقم فاتورة المندوب', 'التاريخ', 'رمز الزبون', 'اسم الزبون',
      'المندوب', 'رمز المادة (ID)', 'الكمية', 'الوحدة', 'السعر', 'الحسم', 'طريقة الدفع',
      'مركز الكلفة', 'المستودع'
    ]);

    int invRow = 1;
    for (var inv in invoices) {
      for (var item in inv.items) {
        _appendRow(invoiceSheet, invRow,[
          inv.invoiceNumber == 0 ? 'غير مزامن' : inv.invoiceNumber,
          inv.delegateInvoiceNumber,
          _formatDate(inv.invoiceDate),
          inv.customerId.isEmpty ? 'زبون نقدي' : inv.customerId,
          inv.customerName,
          inv.delegateId,
          item.productId,
          item.quantity,
          item.unit,
          item.price,
          inv.discount,
          inv.paymentMethod == 'cash' ? 'نقدي' : (inv.paymentMethod == 'gift' ? 'هدية' : 'آجل'),
          inv.costCenterCode,
          inv.warehouseCode
        ]);
        invRow++;
      }
    }

    // ------------------ شيت المرتجعات ------------------
    Sheet returnSheet = excel['مرتجعات المبيعات'];
    _appendRow(returnSheet, 0,[
      'رقم المرتجع', 'رقم مرتجع المندوب', 'التاريخ', 'رمز الزبون', 'اسم الزبون',
      'المندوب', 'رمز المادة (ID)', 'الكمية', 'الوحدة', 'السعر',
      'طريقة الدفع', 'مركز الكلفة', 'المستودع'
    ]);

    int retRow = 1;
    for (var ret in returns) {
      for (var item in ret.items) {
        _appendRow(returnSheet, retRow,[
          ret.returnNumber == 0 ? 'غير مزامن' : ret.returnNumber,
          ret.delegateReturnNumber,
          _formatDate(ret.returnDate),
          ret.customerId,
          ret.customerName,
          ret.delegateId,
          item.productId,
          item.quantity,
          item.unit,
          item.price,
          ret.paymentMethod == 'cash' ? 'نقدي' : 'آجل',
          ret.costCenterCode,
          ret.warehouseCode
        ]);
        retRow++;
      }
    }

    // ------------------ شيت السندات ------------------
    Sheet receiptSheet = excel['سندات القبض'];
    _appendRow(receiptSheet, 0,[
      'رقم السند', 'رقم سند المندوب', 'التاريخ', 'المندوب', 'الحساب الدائن',
      'الحساب المدين', 'المبلغ', 'البيان', 'مركز الكلفة'
    ]);

    int recRow = 1;
    for (var rec in receipts) {
      _appendRow(receiptSheet, recRow,[
        rec.receiptNumber == 0 ? 'غير مزامن' : rec.receiptNumber,
        rec.delegateReceiptNumber,
        _formatDate(rec.date),
        rec.delegateId,
        rec.creditorAccount,
        rec.debtorAccount,
        rec.amount,
        rec.lineNote,
        rec.costCenterCode
      ]);
      recRow++;
    }

    // حفظ الملف ومشاركته مباشرة (تم إلغاء سطر الحذف لحل المشكلة)
    await _saveAndShare(excel, 'Transactions_Export_${_formatDate(DateTime.now())}.xlsx');
  }

  // 2. تصدير الزبائن
  static Future<void> exportCustomers(List<CustomerModel> customers) async {
    var excel = Excel.createExcel();

    Sheet sheet = excel['قائمة الزبائن'];

    _appendRow(sheet, 0,[
      'رمز الحساب', 'الاسم', 'المنطقة', 'الجنس', 'الهاتف1', 'الهاتف2',
      'الإيميل', 'الرصيد الحالي', 'الرصيد السابق', 'المندوب', 'الملاحظات'
    ]);

    int row = 1;
    for (var c in customers) {
      _appendRow(sheet, row,[
        c.accountCode, c.customerName, c.region, c.gender == 'male' ? 'ذكر' : 'أنثى',
        c.phone1, c.phone2, c.email, c.balance, c.previousBalance, c.delegateId, c.notes
      ]);
      row++;
    }

    // حفظ الملف ومشاركته مباشرة (تم إلغاء سطر الحذف لحل المشكلة)
    await _saveAndShare(excel, 'Customers_Export_${_formatDate(DateTime.now())}.xlsx');
  }

  // دالة مساعدة مدرعة 100% ضد الأخطاء والقيم الفارغة
  static void _appendRow(Sheet sheet, int rowIndex, List<dynamic> rowData) {
    for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
      var cellValue = rowData[colIndex];
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex));

      if (cellValue == null) {
        cell.value = '';
      } else if (cellValue is int || cellValue is double) {
        cell.value = cellValue; // الأرقام تُحفظ كأرقام لتتمكن من جمعها في الإكسل
      } else {
        cell.value = cellValue.toString(); // تحويل الباقي لنص آمن
      }
    }
  }

  static String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd_HH-mm').format(date);

  static Future<void> _saveAndShare(Excel excel, String fileName) async {
    var fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      // مشاركة الملف المُصدّر
      await Share.shareXFiles([XFile(filePath)], text: 'مرفق تقرير البيانات');
    }
  }
}