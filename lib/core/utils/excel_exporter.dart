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
  // 1. تصدير المعاملات (فواتير، مرتجعات، سندات) في ملف واحد بـ 3 شيتات
  static Future<void> exportTransactions({
    required List<InvoiceModel> invoices,
    required List<ReturnModel> returns,
    required List<ReceiptModel> receipts,
  }) async {
    var excel = Excel.createExcel();

    // ------------------ شيت الفواتير ------------------
    Sheet invoiceSheet = excel['فواتير'];
    _appendRow(invoiceSheet, 0,[
      'رقم الفاتورة', 'رقم فاتورة المندوب', 'التاريخ', 'رمز الزبون', 'اسم الزبون',
      'المندوب', 'رمز المادة', 'الكمية', 'الوحدة', 'السعر', 'الحسم', 'طريقة الدفع',
      'مركز الكلفة', 'المستودع'
    ]);

    int invRow = 1;
    for (var inv in invoices) {
      for (var item in inv.items) {
        _appendRow(invoiceSheet, invRow,[
          inv.invoiceNumber, inv.delegateInvoiceNumber, _formatDate(inv.invoiceDate),
          inv.customerId, inv.customerName, inv.delegateId, item.productId,
          item.quantity, item.unit, item.price, inv.discount,
          inv.paymentMethod == 'cash' ? 'نقدي' : 'آجل', inv.costCenterCode, inv.warehouseCode
        ]);
        invRow++;
      }
    }

    // ------------------ شيت المرتجعات ------------------
    Sheet returnSheet = excel['مرتجعات'];
    _appendRow(returnSheet, 0,[
      'رقم المرتجع', 'رقم مرتجع المندوب', 'التاريخ', 'رمز الزبون', 'اسم الزبون',
      'المندوب', 'رقم الفاتورة الأصلية', 'رمز المادة', 'الكمية', 'الوحدة', 'السعر',
      'طريقة الدفع', 'مركز الكلفة', 'المستودع'
    ]);

    int retRow = 1;
    for (var ret in returns) {
      for (var item in ret.items) {
        _appendRow(returnSheet, retRow,[
          ret.returnNumber, ret.delegateReturnNumber, _formatDate(ret.returnDate),
          ret.customerId, ret.customerName, ret.delegateId, ret.invoiceRef,
          item.productId, item.quantity, item.unit, item.price,
          ret.paymentMethod == 'cash' ? 'نقدي' : 'آجل', ret.costCenterCode, ret.warehouseCode
        ]);
        retRow++;
      }
    }

    // ------------------ شيت السندات ------------------
    Sheet receiptSheet = excel['سندات'];
    _appendRow(receiptSheet, 0,[
      'رقم السند', 'رقم سند المندوب', 'التاريخ', 'المندوب', 'الحساب الدائن',
      'الحساب المدين', 'المبلغ', 'البيان', 'مركز الكلفة'
    ]);

    int recRow = 1;
    for (var rec in receipts) {
      _appendRow(receiptSheet, recRow,[
        rec.receiptNumber, rec.delegateReceiptNumber, _formatDate(rec.date),
        rec.delegateId, rec.creditorAccount, rec.debtorAccount, rec.amount,
        rec.lineNote, rec.costCenterCode
      ]);
      recRow++;
    }

    excel.delete('Sheet1'); // حذف الشيت الافتراضي الفارغ
    await _saveAndShare(excel, 'Transactions_Export_${_formatDate(DateTime.now())}.xlsx');
  }

  // 2. تصدير الزبائن
  static Future<void> exportCustomers(List<CustomerModel> customers) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['الزبائن'];

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

    excel.delete('Sheet1');
    await _saveAndShare(excel, 'Customers_Export_${_formatDate(DateTime.now())}.xlsx');
  }

  // دوال مساعدة لترتيب وتنسيق الإكسل (تم تعديلها لتتوافق مع الإصدار الموجود لديك مباشرة)
  static void _appendRow(Sheet sheet, int rowIndex, List<dynamic> rowData) {
    for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
      var cellValue = rowData[colIndex];
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex));

      // التعيين المباشر للقيمة وهو ما تتطلبه النسخة المثبتة لديك
      cell.value = cellValue;
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
      await Share.shareXFiles([XFile(filePath)], text: 'مرفق ملف البيانات');
    }
  }
}