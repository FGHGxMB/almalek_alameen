// lib/core/utils/excel_exporter.dart

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:spice_app/data/models/product_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/return_model.dart';
import '../../data/models/receipt_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/user_model.dart';

class ExcelExporter {
  // 1. تصدير المعاملات (فواتير، مرتجعات، سندات)
  static Future<void> exportTransactions({
    required List<InvoiceModel> invoices,
    required List<ReturnModel> returns,
    required List<ReceiptModel> receipts,
    required Map<String, UserModel> usersMap,
    required Map<String, CustomerModel> customersMap, // الخريطة الجديدة للزبائن
    required Map<String, ProductModel> productsMap,   // الخريطة الجديدة للمواد
  }) async {
    var excel = Excel.createExcel();

    // =========================================================================
    // ------------------ شيت الفواتير ------------------
    // =========================================================================
    Sheet invoiceSheet = excel['فواتير المبيعات'];
    _appendRow(invoiceSheet, 0,[
      'رقم الفاتورة', 'تاريخ الفاتورة', 'رمز الحساب', 'اسم الزبون', 'رمز المستودع',
      'رمز المادة', 'الكمية', 'الوحدة', 'السعر الافرادي', 'طريقة الدفع', 'رمز العملة',
      'بيان الفاتورة'
    ]);

    int invRow = 1;
    for (var inv in invoices) {
      final user = usersMap[inv.delegateId];
      final cashBox = user?.cashBoxCode ?? '';

      String accountCode = '';
      if (inv.paymentMethod == 'cash' || inv.paymentMethod == 'gift') {
        accountCode = cashBox; // صندوق المندوب
      } else {
        // السحر هنا: جلب رمز الزبون بدلاً من الـ ID
        accountCode = customersMap[inv.customerId]?.accountCode ?? inv.customerId;
      }

      String formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(inv.createdAt);
      String modifiedStr = '';
      if (inv.updatedAt.difference(inv.createdAt).inMinutes > 1) {
        modifiedStr = ' (تعديلها في: ${DateFormat('dd-MM-yyyy hh:mm a').format(inv.updatedAt)})';
      }
      String fullNote = 'فاتورة رقم: ${inv.delegateInvoiceNumber.toString().padLeft(5, '0')} $formattedDate$modifiedStr';
      if (inv.invoiceNote.isNotEmpty) fullNote += ' ملاحظة: ${inv.invoiceNote}';

      for (var item in inv.items) {
        // السحر هنا: جلب رمز المادة بدلاً من الـ ID
        String itemCode = productsMap[item.productId]?.itemCode ?? item.productId;

        _appendRow(invoiceSheet, invRow,[
          inv.delegateInvoiceNumber.toString().padLeft(5, '0'),
          DateFormat('yyyy-MM-dd').format(inv.invoiceDate),
          accountCode,
          inv.customerId.isEmpty ? '' : inv.customerName,
          inv.warehouseCode,
          itemCode, // <--- رمز المادة الصحيح
          item.quantity,
          item.unit,
          item.price,
          inv.paymentMethod == 'credit' ? '1' : '0',
          'ل.س.',
          fullNote,
        ]);
        invRow++;
      }
    }

    // =========================================================================
    // ------------------ شيت المرتجعات ------------------
    // =========================================================================
    Sheet returnSheet = excel['مرتجعات المبيعات'];
    _appendRow(returnSheet, 0,[
      'رقم الفاتورة', 'تاريخ الفاتورة', 'رمز الحساب', 'اسم الزبون', 'رمز المستودع',
      'رمز المادة', 'الكمية', 'الوحدة', 'السعر الافرادي', 'طريقة الدفع', 'رمز العملة',
      'بيان الفاتورة'
    ]);

    int retRow = 1;
    for (var ret in returns) {
      final user = usersMap[ret.delegateId];
      final cashBox = user?.cashBoxCode ?? '';

      String accountCode = (ret.paymentMethod == 'cash') ? cashBox : (customersMap[ret.customerId]?.accountCode ?? ret.customerId);

      String formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(ret.createdAt);
      String modifiedStr = '';
      if (ret.updatedAt.difference(ret.createdAt).inMinutes > 1) {
        modifiedStr = ' (تعديلها في: ${DateFormat('dd-MM-yyyy hh:mm a').format(ret.updatedAt)})';
      }
      String fullNote = 'مرتجع رقم: ${ret.delegateReturnNumber.toString().padLeft(5, '0')} $formattedDate$modifiedStr';
      if (ret.returnNote.isNotEmpty) fullNote += ' ملاحظة: ${ret.returnNote}';

      for (var item in ret.items) {
        String itemCode = productsMap[item.productId]?.itemCode ?? item.productId;

        _appendRow(returnSheet, retRow,[
          ret.delegateReturnNumber.toString().padLeft(5, '0'),
          DateFormat('yyyy-MM-dd').format(ret.returnDate),
          accountCode,
          ret.customerId.isEmpty ? '' : ret.customerName,
          ret.warehouseCode,
          itemCode, // <--- رمز المادة الصحيح
          item.quantity,
          item.unit,
          item.price,
          ret.paymentMethod == 'credit' ? '1' : '0',
          'ل.س.',
          fullNote,
        ]);
        retRow++;
      }
    }

    // =========================================================================
    // ------------------ شيت السندات ------------------
    // =========================================================================
    Sheet receiptSheet = excel['سندات القبض'];
    _appendRow(receiptSheet, 0,[
      'رقم السند', 'التاريخ', 'رمز الحساب الدائن', 'رمز الحساب المدين', 'المبلغ', 'البيان'
    ]);

    int recRow = 1;
    for (var rec in receipts) {
      final user = usersMap[rec.delegateId];
      final cashBox = user?.cashBoxCode ?? '';

      String creditorCode = customersMap[rec.creditorAccount]?.accountCode ?? rec.creditorAccount;

      String formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(rec.createdAt);
      String modifiedStr = '';
      if (rec.updatedAt.difference(rec.createdAt).inMinutes > 1) {
        modifiedStr = ' (تعديله في: ${DateFormat('dd-MM-yyyy hh:mm a').format(rec.updatedAt)})';
      }
      String fullNote = 'سند رقم: ${rec.delegateReceiptNumber.toString().padLeft(5, '0')} $formattedDate$modifiedStr';
      if (rec.lineNote.isNotEmpty) fullNote += ' ملاحظة: ${rec.lineNote}';

      _appendRow(receiptSheet, recRow,[
        rec.delegateReceiptNumber.toString().padLeft(5, '0'),
        DateFormat('yyyy-MM-dd').format(rec.date),
        creditorCode, // <--- رمز حساب الزبون الصحيح
        cashBox,
        rec.amount,
        fullNote
      ]);
      recRow++;
    }

    await _saveAndShare(excel, 'Transactions_Export_${_formatDate(DateTime.now())}.xlsx');
  }

  // =========================================================================
  // 2. تصدير الزبائن
  // =========================================================================
  static Future<void> exportCustomers({
    required List<CustomerModel> customers,
    required Map<String, UserModel> usersMap,
  }) async {
    var excel = Excel.createExcel();

    Sheet sheet = excel['قائمة الزبائن'];

    _appendRow(sheet, 0,[
      'اسم الزبون', 'رمز حسابه', 'رمز الحساب الرئيسي', 'رمز العملة', 'هاتف1', 'هاتف2',
      'ملاحظات', 'اسم الدولة', 'اسم المدينة', 'اسم المنطقة', 'الحي', 'الشارع', 'الجنس', 'الرصيد السابق'
    ]);

    int row = 1;
    for (var c in customers) {
      final user = usersMap[c.delegateId];
      final mainAccountCode = user?.mainCustomerAccount ?? '';

      // String cleanName = c.customerName;
      // if (user != null && user.customerSuffix.isNotEmpty && cleanName.startsWith(user.customerSuffix)) {
      //   cleanName = cleanName.replaceFirst(user.customerSuffix, '').trim();
      // }
      // if (cleanName.endsWith(' - ${c.region}')) {
      //   cleanName = cleanName.substring(0, cleanName.length - (' - ${c.region}').length).trim();
      // }

      _appendRow(sheet, row,[
        // cleanName,
        c.customerName,
        c.accountCode,
        mainAccountCode,
        'ل.س.',
        c.phone1,
        c.phone2,
        c.notes,
        c.country,
        c.city,
        c.region,
        c.district,
        c.street,
        c.gender == 'male' ? 'ذكر' : 'أنثى',
        c.previousBalance
      ]);
      row++;
    }

    await _saveAndShare(excel, 'Customers_Export_${_formatDate(DateTime.now())}.xlsx');
  }

  static void _appendRow(Sheet sheet, int rowIndex, List<dynamic> rowData) {
    for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
      var cellValue = rowData[colIndex];
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex));

      if (cellValue == null) {
        cell.value = '';
      } else if (cellValue is int || cellValue is double) {
        cell.value = cellValue;
      } else {
        cell.value = cellValue.toString();
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
      await Share.shareXFiles([XFile(filePath)], text: 'مرفق تقرير البيانات');
    }
  }
}