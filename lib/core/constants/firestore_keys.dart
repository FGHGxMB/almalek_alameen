// lib/core/constants/firestore_keys.dart

class FirestoreKeys {
  // Collections
  static const String users = 'users';
  static const String settings = 'settings';
  static const String products = 'products';
  static const String customers = 'customers';
  static const String invoices = 'invoices';
  static const String returns = 'returns';
  static const String receipts = 'receipts';
  static const String companyAccounts = 'company_accounts';
  static const String dailyCash = 'daily_cash'; // Sub-collection under user

  // Common Fields
  static const String id = 'id';
  static const String isActive = 'isActive';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String delegateId = 'delegate_id';
  static const String isSynced = 'is_synced';
  static const String pendingAction = 'pending_action';
  static const String warehouseCode = 'warehouse_code';
  static const String costCenterCode = 'cost_center';

  // App Config / Settings Fields
  static const String appConfigDoc = 'app_config';
  static const String mainCashAccount = 'main_cash_account';
  static const String areas = 'areas';
  static const String areasVersion = 'areas_version';
  static const String currencyRate = 'currency_rate';
  static const String productsVersion = 'products_version';
  static const String appVersion = 'app_version';
  static const String invoiceCounter = 'invoice_counter';
  static const String returnCounter = 'return_counter';
  static const String receiptCounter = 'receipt_counter';

  // User Fields
  static const String accountName = 'account_name';
  static const String email = 'email';
  static const String rank = 'rank';
  static const String mainCustomerAccount = 'main_customer_account';
  static const String customerSuffix = 'customer_suffix';
  static const String canMonitor = 'can_monitor';
  static const String delegateInvoiceCounter = 'delegate_invoice_counter';
  static const String delegateReturnCounter = 'delegate_return_counter';
  static const String delegateReceiptCounter = 'delegate_receipt_counter';
  static const String customerCounter = 'customer_counter';
  static const String permissions = 'permissions';
  static const String accountColor = 'account_color';

  // Product Fields
  static const String itemCode = 'item_code';
  static const String itemName = 'item_name';
  static const String groupCode = 'group_code';
  static const String currencyCode = 'currency_code';
  static const String unit1 = 'unit1';
  static const String barcode1 = 'barcode1';
  static const String shopPrice1 = 'shop_price1';
  static const String consumerPrice1 = 'consumer_price1';
  static const String unit2 = 'unit2';
  static const String barcode2 = 'barcode2';
  static const String shopPrice2 = 'shop_price2';
  static const String consumerPrice2 = 'consumer_price2';
  static const String unit3 = 'unit3';
  static const String barcode3 = 'barcode3';
  static const String shopPrice3 = 'shop_price3';
  static const String consumerPrice3 = 'consumer_price3';
  static const String defaultUnit = 'default_unit';

  // New Product Display Fields (Tabs & Columns)
  static const String tabName = 'tab_name';
  static const String columnIndex = 'column_index';
  static const String rowIndex = 'row_index';

  // Customer Fields
  static const String accountCode = 'account_code';
  static const String customerName = 'customer_name';
  static const String phone1 = 'phone1';
  static const String phone2 = 'phone2';
  static const String notes = 'notes';
  static const String country = 'country';
  static const String city = 'city';
  static const String region = 'region';
  static const String district = 'district';
  static const String street = 'street';
  static const String gender = 'gender';
  static const String previousBalance = 'previous_balance';
  static const String balance = 'balance';
  static const String lastTransactionDate = 'last_transaction_date';

  // Transaction Fields (Invoices, Returns)
  static const String invoiceNumber = 'invoice_number';
  static const String delegateInvoiceNumber = 'delegate_invoice_number';
  static const String returnNumber = 'return_number';
  static const String delegateReturnNumber = 'delegate_return_number';
  static const String invoiceDate = 'invoice_date';
  static const String returnDate = 'return_date';
  static const String customerId = 'customer_id'; // The Document ID, not the code
  static const String paymentMethod = 'payment_method';
  static const String invoiceNote = 'invoice_note';
  static const String returnNote = 'return_note';
  static const String discount = 'discount';
  static const String invoiceRef = 'invoice_ref';
  static const String items = 'items';

  // Transaction Item Fields
  static const String productId = 'product_id'; // The Document ID
  static const String quantity = 'quantity';
  static const String unit = 'unit';
  static const String price = 'price';

  // Receipt Fields
  static const String receiptNumber = 'receipt_number';
  static const String delegateReceiptNumber = 'delegate_receipt_number';
  static const String creditorAccount = 'creditor_account'; // Could be ID
  static const String debtorAccount = 'debtor_account'; // Could be ID
  static const String amount = 'amount';
  static const String lineNote = 'line_note';
  static const String date = 'date';
}