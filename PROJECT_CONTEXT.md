# PROJECT CONTEXT — تطبيق إدارة مندوبي توزيع البهارات

---

## ١. هوية النموذج ودوره

أنت مهندس برمجيات أول متخصص في Flutter وFirebase مع خبرة تزيد على عشر سنوات في بناء تطبيقات Android احترافية. دورك في هذا المشروع هو **الإشراف على التنفيذ خطوة بخطوة**:

- تكتب كوداً كاملاً جاهزاً للتشغيل — لا اختصار ولا حذف ولا "أكمل الباقي بنفسك"
- تراجع كل ما يُنفَّذ وتصحح الأخطاء
- تلتزم بهذا الـ Project Context في كل رد دون استثناء
- إذا طُلب منك شيء يتعارض مع هذا السياق، تنبّه وتوضح قبل التنفيذ

---

## ٢. وصف المشروع

### ما هو التطبيق؟
تطبيق Flutter داخلي لشركة طحن وتوزيع بهارات. يُرقمن عمل فريق المندوبين الميدانيين بالكامل. **لا يراه الزبائن أبداً** — هو أداة عمل داخلية حصراً.

### المشكلة التي يحلها
الشركة تعمل بطرق يدوية وبدائية: فواتير ورقية، أرصدة غير محدّثة، لا رقابة فورية على أداء المندوبين، لا سجل موحد للمعاملات. التطبيق يحل هذه المشكلة بالكامل.

### المنصة
**Android فقط** — لا iOS في هذا الإصدار.

### البيئة
الباكند Firebase بالكامل. لا سيرفر مخصص. لا API خارجي.

---

## ٣. المستخدمون وطبيعة الصلاحيات

### القاعدة الجوهرية
النظام **لا يعرف أدواراً ثابتة** (لا يوجد role: "delegate" أو role: "supervisor"). كل الحسابات بنية واحدة والفرق بينها فقط **الصلاحيات** التي يمنحها المدير. حساب ما قد يكون مندوباً ومشرفاً في نفس الوقت.

### أنواع المستخدمين عملياً

**المندوب الميداني**
يستخدم التطبيق طوال يوم عمله. يسجل زبائن جدد، ينشئ فواتير مبيعات ويطبعها فوراً على طابعة WiFi، ينشئ مرتجعات مبيعات، يسجل سندات قبض عند استلام مبالغ من الزبائن، يراجع أرصدة زبائنه.

**المشرف**
يراقب بيانات المندوبين المحددين في قائمة `can_monitor` الخاصة به. لا ينشئ عمليات إلا إذا مُنح صلاحية صريحة.

**المدير**
يتحكم في كل شيء من صفحة Admin داخل التطبيق. الصفحة تظهر فقط لمن لديه `admin_access: true` في permissions.

### قاعدة عرض البيانات
كل مستخدم يرى دائماً بياناته الخاصة تلقائياً + بيانات كل uid في قائمة `can_monitor`. الجلب **دائماً**:
```dart
where("delegate_id", whereIn: [myUid, ...can_monitor])
```

---

## ٤. التقنيات المستخدمة — لا تحيد عنها أبداً

| التقنية | الاستخدام | الحزمة |
|---|---|---|
| Flutter | إطار العمل الرئيسي — Android فقط | SDK |
| Dart | لغة البرمجة | — |
| Firebase Auth | المصادقة — Email/Password فقط | `firebase_auth` |
| Cloud Firestore | قاعدة البيانات الرئيسية | `cloud_firestore` |
| Cloud Functions | منطق الباكند (TypeScript) | `cloud_functions` |
| flutter_bloc | إدارة الحالة — Cubit بالتحديد | `flutter_bloc` |
| go_router | التنقل بين الشاشات | `go_router` |
| shared_preferences | التخزين المحلي (فلاتر، إصدارات، كاش) | `shared_preferences` |
| excel | تصدير ملفات Excel | `excel` |
| share_plus | مشاركة الملفات المُصدَّرة | `share_plus` |
| intl | تنسيق التواريخ والأرقام | `intl` |
| esc_pos_utils + esc_pos_printer | طباعة الفواتير عبر WiFi | مكتبتان منفصلتان |
✅ drift (SQLite) — للمواد والبيانات المحلية القابلة للاستعلام ✅ SharedPreferences — للإعدادات البسيطة والفلاتر والـ versions
### ما لا يُستخدم أبداً
- ❌ Provider أو Riverpod أو GetX — نستخدم Bloc/Cubit فقط
- ❌ GetIt أو injectable — Dependency Injection يدوي عبر constructors
- ❌ Dio أو http — لا API خارجي
- ❌ أي حزمة state management أخرى

---

## ٥. بنية Firestore الكاملة

### 📁 `settings/app_config` — وثيقة واحدة ثابتة
```
main_cash_account: String       // رمز حساب الصندوق الرئيسي
areas: [String]                 // قائمة المناطق — لا يعدلها أحد من التطبيق
areas_version: Number           // يتغير عند تعديل المناطق
currency_rate: Number           // سعر الدولار
products_version: Number        // يتغير عند تعديل المواد
app_version: String
invoice_counter: Number         // العداد العام لفواتير المبيعات
return_counter: Number          // العداد العام للمرتجعات
receipt_counter: Number         // العداد العام لسندات القبض
```

### 📁 `users/{uid}`
```
account_name: String
email: String                       // للعرض — يُحدَّث مع Auth دائماً معاً
rank: String                        // نص حر يكتبه المدير
warehouse_code: String              // رمز مستودع هذا الحساب
main_customer_account: String       // البادئة الرقمية لرمز زبائن هذا المندوب
cost_center_code: String
customer_suffix: String             // لاحقة تُضاف لاسم الزبون في البداية
can_monitor: [String]               // قائمة uid الحسابات التي يراقبها
isActive: Boolean
delegate_invoice_counter: Number
delegate_return_counter: Number
delegate_receipt_counter: Number
customer_counter: Number            // عداد لتوليد رمز الزبون

permissions: {
  admin_access: Boolean,
  export_data: Boolean,
  company_accounts_view: Boolean,
  company_accounts_edit: Boolean,
  invoice_create: Boolean,
  invoice_edit: Boolean,
  invoice_delete: Boolean,
  return_create: Boolean,
  return_edit: Boolean,
  return_delete: Boolean,
  receipt_create: Boolean,
  receipt_edit: Boolean,
  receipt_delete: Boolean,
  customer_create: Boolean,
  customer_edit: Boolean,
  customer_delete: Boolean
}
```

### 📁 `users/{uid}/daily_cash/{YYYY-MM-DD}` — Subcollection
```
amount: Number          // الكاش المتراكم في هذا اليوم — يبدأ من 0 كل يوم
date: Timestamp
```
**قاعدة:** يُعدَّل فقط عبر Cloud Functions. التطبيق لا يكتب فيه أبداً. قراءة فقط.

**ما يؤثر على الكاش:**
- فاتورة مبيعات نقدية → يزيد بقيمة الفاتورة بعد الحسم
- فاتورة مبيعات آجلة → لا أثر على الكاش (يزيد رصيد الزبون)
- مرتجع نقدي → ينقص من الكاش
- مرتجع آجل → لا أثر على الكاش (ينقص رصيد الزبون)
- سند قبض → يزيد الكاش + ينقص رصيد الزبون

### 📁 `products/{item_code}`
الـ document ID = item_code. لا يُحذف أي document أبداً — فقط `isActive: false`.
```
item_code: String
item_name: String
group_code: String
currency_code: String
unit1: String,  barcode1: String,  shop_price1: Number,  consumer_price1: Number
unit2: String,  barcode2: String,  shop_price2: Number,  consumer_price2: Number
unit3: String,  barcode3: String,  shop_price3: Number,  consumer_price3: Number
default_unit: String
isActive: Boolean
```

### 📁 `customers/{customer_id}`
```
account_code: String        // يُولَّد تلقائياً: main_customer_account + customer_counter
                            // مثال: 102 + 15 = "10215"
customer_name: String       // يُبنى تلقائياً: "{customer_suffix} {ما يكتبه المندوب} - {المنطقة}"
                            // مثال: "مول أبو أحمد - الرياض"
phone1: String              // اختياري
phone2: String              // اختياري
email: String               // اختياري
notes: String               // اختياري
country: String             // نص ثابت لا يتغير — يحدده المدير من الإعدادات
city: String                // نص ثابت لا يتغير — يحدده المدير من الإعدادات
region: String              // إلزامي — يختار من قائمة areas فقط
district: String            // اختياري
street: String              // اختياري
gender: String              // إلزامي — "male" | "female"
previous_balance: Number    // الرصيد السابق قبل التطبيق — يُكتب مباشرة كـ balance
balance: Number             // يُحدَّث تلقائياً عبر Function فقط
delegate_id: String
```

**الحقول الإلزامية عند الإنشاء:** `region` + `gender` + اسم الزبون (الجزء الذي يكتبه المندوب)

### 📁 `invoices/{invoice_id}`
**مهم:** لا يُخزَّن اسم المادة — يُجلب من products عند العرض باستخدام item_code.
```
invoice_number: Number              // الرقم العام — يُعبَّأ بعد الـ sync فقط (Function)
delegate_invoice_number: Number     // الرقم المحلي — يُعبَّأ فوراً من الجهاز
invoice_date: Timestamp
account_code: String
customer_name: String               // للعرض السريع فقط
warehouse_code: String              // يُسحب تلقائياً من بيانات المندوب
payment_method: String              // "cash" | "credit"
invoice_note: String
discount: Number
cost_center: String                 // يُسحب تلقائياً من بيانات المندوب
is_synced: Boolean                  // false = لم يُرفع للسيرفر — يظهر بلون مميز
pending_action: String              // "create" | "update" | "delete"
created_at: Timestamp
updated_at: Timestamp
delegate_id: String
items: [
  {
    item_code: String,
    quantity: Number,
    unit: String,
    price: Number
  }
]
```

### 📁 `returns/{return_id}`
```
return_number: Number
delegate_return_number: Number
return_date: Timestamp
account_code: String
customer_name: String
warehouse_code: String
payment_method: String              // "cash" | "credit"
return_note: String
invoice_ref: String                 // اختياري — رقم الفاتورة الأصلية
cost_center: String
is_synced: Boolean
pending_action: String              // "create" | "update" | "delete"
created_at: Timestamp
updated_at: Timestamp
delegate_id: String
items: [
  {
    item_code: String,
    quantity: Number,
    unit: String,
    price: Number
  }
]
```

### 📁 `receipts/{receipt_id}`
```
receipt_number: Number
delegate_receipt_number: Number
creditor_account: String
debtor_account: String
amount: Number
line_note: String
cost_center: String                 // يُسحب تلقائياً من بيانات المندوب
date: Timestamp
is_synced: Boolean
pending_action: String              // "create" | "update" | "delete"
created_at: Timestamp
updated_at: Timestamp
delegate_id: String
```

### 📁 `company_accounts/{account_id}`
حسابات الشركة للعرض فقط — لا فواتير ولا حركات. يضيفها المدير يدوياً.
```
account_name: String
balance: Number
account_type: String                // "customer" | "supplier"
theme_color: String
background_color: String
created_at: Timestamp
updated_at: Timestamp
```

---

## ٦. آليات جوهرية

### آلية تحميل المواد والمناطق
**المواد:**
1. عند فتح التطبيق: اقرأ `products_version` من `settings/app_config`
2. قارنه بالرقم المحفوظ في SharedPreferences
3. إذا تطابقا → استخدم النسخة المحلية، لا طلبات للسيرفر
4. إذا اختلفا → احذف المحلي كاملاً، حمّل products/ كاملة، احفظ محلياً، حدّث الرقم

**المناطق:** نفس الآلية بالضبط باستخدام `areas_version`.

### آلية الأرقام التسلسلية

| النوع | الرقم المحلي (فوري - offline) | الرقم العام (بعد sync - Function) |
|---|---|---|
| فاتورة مبيعات | `delegate_invoice_number` | `invoice_number` |
| مرتجع | `delegate_return_number` | `return_number` |
| سند قبض | `delegate_receipt_number` | `receipt_number` |

**الأرقام المحلية:** تُقرأ من `users/{uid}` المحفوظ محلياً، تزيد 1، تُكتب في الوثيقة فوراً.
**الأرقام العامة:** تُنشئها Cloud Function عبر Transaction عند رفع الوثيقة. تبدأ من 1 بدون أصفار.

### آلية الـ Offline
- Firestore Offline Persistence مُفعَّل مع `cacheSizeBytes: CACHE_SIZE_UNLIMITED`
- أي وثيقة `is_synced: false` تظهر بلون مميز في القائمة (برتقالي أو مائل للرمادي)
- عند عودة الإنترنت يُزامَن كل شيء تلقائياً عبر Firestore
- الـ Function تقرأ `pending_action` وتتصرف بناءً عليها
- بعد الـ sync: `is_synced: true` + `pending_action: ""`

### آلية بناء رمز واسم الزبون
```
account_code = main_customer_account + customer_counter
// مثال: "102" + "15" = "10215"

customer_name = customer_suffix + " " + [ما يكتبه المندوب] + " - " + region
// مثال: "مول" + " " + "أبو أحمد" + " - " + "الرياض" = "مول أبو أحمد - الرياض"
```

### آلية الفلاتر
- الفلاتر **مؤقتة بالافتراضي** — تُمسح عند إعادة فتح التطبيق
- زر "تطبيق كافتراضي" يحفظ الفلاتر الحالية في SharedPreferences
- زر "مسح الفلاتر" يعود للحالة الافتراضية
- يمكن تطبيق عدة فلاتر في نفس الوقت

---

## ٧. Cloud Functions الكاملة (TypeScript)

| الـ Function | المُشغِّل | ما تفعله داخل Transaction |
|---|---|---|
| `onInvoiceCreate` | onCreate في invoices/ | invoice_counter+1، delegate_invoice_counter+1، كتابة الرقمين. نقدي: daily_cash+قيمة. آجل: balance الزبون +قيمة |
| `onInvoiceUpdate` | onUpdate في invoices/ | يحسب الفرق (جديد - قديم) ويطبقه على الكاش أو الرصيد |
| `onInvoiceDelete` | onDelete في invoices/ | يعكس الأثر الكامل |
| `onReturnCreate` | onCreate في returns/ | return_counter+1، delegate_return_counter+1. نقدي: daily_cash-قيمة. آجل: balance الزبون -قيمة |
| `onReturnUpdate` | onUpdate في returns/ | يحسب الفرق ويطبقه معكوساً |
| `onReturnDelete` | onDelete في returns/ | يعكس الأثر |
| `onReceiptCreate` | onCreate في receipts/ | receipt_counter+1، delegate_receipt_counter+1، daily_cash+المبلغ، balance الزبون -المبلغ |
| `onReceiptUpdate` | onUpdate في receipts/ | يحسب الفرق ويطبقه |
| `onReceiptDelete` | onDelete في receipts/ | يعكس الأثر |
| `adminCreateUser` | HTTP callable | ينشئ حساباً في Firebase Auth ثم document في users/{uid} |
| `adminUpdateUser` | HTTP callable | يعدّل الإيميل في Auth وفي Firestore معاً |
| `adminChangePassword` | HTTP callable | يغير كلمة السر في Auth ويُلغي جلسة المستخدم فوراً |
| `adminDeleteUser` | HTTP callable | يحذف فقط إذا لم يكن للحساب فواتير أو سندات أو زبائن |

**قاعدة الكاش اليومي داخل كل Function:** تتحقق إذا كان document اليوم موجوداً (`daily_cash/{YYYY-MM-DD}`)، إذا لم يكن تنشئه بـ `amount: 0` ثم تطبق الأثر — كل ذلك داخل نفس الـ Transaction.

---

## ٨. خريطة الشاشات الكاملة

```
┌─────────────────────────────────┐
│      شاشة تسجيل الدخول           │
│  إيميل + كلمة سر + زر دخول      │
│  لا "نسيت كلمة السر"             │
└──────────────┬──────────────────┘
               ↓
┌──────────────────────────────────────────────────────────┐
│            شريط التنقل السفلي — 5 تبويبات                │
└──────────────────────────────────────────────────────────┘

① Dashboard
   ├── كاش اليوم (من daily_cash/{today} — قراءة فقط)
   ├── إحصاء الفواتير: عدد نقدي | عدد آجل | الإجمالي
   ├── الحركة المالية: تحصيلات نقدية | زيادة ديون | ديون محصّلة
   └── فلاتر: تاريخ محدد + تحديد مندوبين (لمن يملك can_monitor)

② المعاملات
   ├── قائمة موحدة: فواتير + مرتجعات + سندات في شاشة واحدة
   ├── الوثائق is_synced: false تظهر بلون مميز
   ├── فلاتر متقدمة:
   │     النوع (فاتورة/مرتجع/سند) | التاريخ من/إلى | عدة مندوبين
   │     الزبون | طريقة الدفع (نقدي/آجل) | قيمة الفاتورة | قيمة الحسم
   ├── زر "تطبيق كافتراضي" + زر "مسح الفلاتر"
   ├── تحديد عدة عناصر + تصدير Excel (بصلاحية export_data فقط)
   └── إنشاء: فاتورة | مرتجع | سند (بالصلاحية المقابلة)

   شاشة إنشاء/تعديل فاتورة:
   ├── اختيار الزبون (من زبائن [myUid, ...can_monitor] فقط)
   ├── إضافة أقلام من المواد المحلية (item_code + quantity + unit + price)
   ├── حسم + طريقة الدفع (نقدي/آجل) + بيان
   └── warehouse_code و cost_center يُسحبان تلقائياً

③ الزبائن
   ├── قائمة مفلترة بالمنطقة والاسم والرصيد
   ├── فلاتر مؤقتة + زر "تطبيق كافتراضي" + زر "مسح"
   ├── تصدير Excel للزبائن المحددين (بصلاحية export_data)
   └── إضافة زبون جديد (بصلاحية customer_create):
         إلزامي: المنطقة (من قائمة areas) + الجنس + اسم الزبون + الرصيد السابق
         اختياري: هاتف1 + هاتف2 + إيميل + ملاحظات + حي + شارع

④ حسابات الشركة (يظهر فقط بصلاحية company_accounts_view)
   ├── قائمة موردين وزبائن مع أرصدتهم
   ├── ثيمات لونية (تُحفظ محلياً على الجهاز — كل مستخدم له تفضيلاته)
   ├── 3 ثيمات على الأقل جاهزة مسبقاً
   └── إضافة/تعديل/حذف (بصلاحية company_accounts_edit)

⑤ الإعدادات
   ├── تعديل الإيميل
   ├── تغيير كلمة السر
   ├── تسجيل الخروج
   └── [يظهر فقط بصلاحية admin_access] زر → صفحة الأدمين:
         ├── إعدادات عامة: main_cash_account | currency_rate | app_version
         └── قائمة كل الحسابات → صفحة تعديل حساب:
               account_name | email | rank | warehouse_code
               main_customer_account | cost_center_code | customer_suffix
               can_monitor | isActive | كل permissions بـ Toggle
               + زر تغيير كلمة السر
```

---

## ٩. تصدير Excel — هيكل الملفات

### من شاشة المعاملات
ملف واحد بـ 3 شيتات:

**شيت "فواتير"** — كل قلم في صف مستقل:
`رقم الفاتورة | رقم فاتورة المندوب | التاريخ | رمز الزبون | اسم الزبون | المندوب | رمز المادة | الكمية | الوحدة | السعر | الحسم | طريقة الدفع | مركز الكلفة | المستودع`

**شيت "مرتجعات"** — نفس الهيكل:
`رقم المرتجع | رقم مرتجع المندوب | التاريخ | رمز الزبون | اسم الزبون | المندوب | رقم الفاتورة الأصلية | رمز المادة | الكمية | الوحدة | السعر | طريقة الدفع | مركز الكلفة | المستودع`

**شيت "سندات"**:
`رقم السند | رقم سند المندوب | التاريخ | المندوب | الحساب الدائن | الحساب المدين | المبلغ | البيان | مركز الكلفة`

### من شاشة الزبائن
ملف واحد بشيت واحد — كل زبون في صف:
`رمز الحساب | الاسم | المنطقة | الجنس | الهاتف1 | الهاتف2 | الإيميل | الرصيد | الرصيد السابق | المندوب | الملاحظات`

---

## ١٠. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAdmin() {
      return request.auth.uid == 'ADMIN_UID'; // استبدل بالـ UID الحقيقي
    }

    function userData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }

    function isActive() {
      return userData().isActive == true;
    }

    function canMonitor(delegateId) {
      return delegateId == request.auth.uid ||
             delegateId in userData().can_monitor;
    }

    function hasPermission(perm) {
      return userData().permissions[perm] == true;
    }

    match /settings/{doc} {
      allow read: if request.auth != null && isActive();
      allow write: if isAdmin();
    }

    match /products/{itemCode} {
      allow read: if request.auth != null && isActive();
      allow create, update: if isAdmin();
      allow delete: if false; // محظور على الجميع بدون استثناء
    }

    match /users/{uid} {
      allow read: if request.auth.uid == uid || isAdmin();
      allow write: if isAdmin();

      match /daily_cash/{date} {
        allow read: if request.auth.uid == uid ||
                       (isActive() && canMonitor(uid));
        allow write: if false; // Functions فقط
      }
    }

    match /customers/{customerId} {
      allow read: if isActive() && canMonitor(resource.data.delegate_id);
      allow create: if isActive() && hasPermission('customer_create');
      allow update: if isActive() && hasPermission('customer_edit') &&
                       resource.data.delegate_id == request.auth.uid;
      allow delete: if isActive() && hasPermission('customer_delete') &&
                       resource.data.delegate_id == request.auth.uid;
    }

    match /invoices/{invoiceId} {
      allow read: if isActive() && canMonitor(resource.data.delegate_id);
      allow create: if isActive() && hasPermission('invoice_create');
      allow update: if isActive() && hasPermission('invoice_edit') &&
                       resource.data.delegate_id == request.auth.uid;
      allow delete: if isActive() && hasPermission('invoice_delete') &&
                       resource.data.delegate_id == request.auth.uid;
    }

    match /returns/{returnId} {
      allow read: if isActive() && canMonitor(resource.data.delegate_id);
      allow create: if isActive() && hasPermission('return_create');
      allow update: if isActive() && hasPermission('return_edit') &&
                       resource.data.delegate_id == request.auth.uid;
      allow delete: if isActive() && hasPermission('return_delete') &&
                       resource.data.delegate_id == request.auth.uid;
    }

    match /receipts/{receiptId} {
      allow read: if isActive() && canMonitor(resource.data.delegate_id);
      allow create: if isActive() && hasPermission('receipt_create');
      allow update: if isActive() && hasPermission('receipt_edit') &&
                       resource.data.delegate_id == request.auth.uid;
      allow delete: if isActive() && hasPermission('receipt_delete') &&
                       resource.data.delegate_id == request.auth.uid;
    }

    match /company_accounts/{accountId} {
      allow read: if isActive() && hasPermission('company_accounts_view');
      allow write: if isActive() && hasPermission('company_accounts_edit');
    }
  }
}
```

---

## ١١. هيكل مشروع Flutter

```
lib/
├── main.dart                         // Firebase init + Offline Persistence
├── firebase_options.dart
│
├── core/
│   ├── constants/
│   │   ├── firestore_keys.dart       // ⚠️ كل أسماء حقول Firestore ثوابت String هنا فقط
│   │   ├── app_colors.dart
│   │   ├── app_themes.dart           // 3 ثيمات على الأقل
│   │   └── app_routes.dart           // مسارات go_router
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   └── printer_service.dart      // Rongta RPP300 - WiFi - ESC/POS
│   └── utils/
│       ├── account_code_generator.dart   // توليد رمز الزبون
│       ├── customer_name_builder.dart    // بناء اسم الزبون
│       └── invoice_calculator.dart      // حساب إجمالي الفاتورة بعد الحسم
│
├── data/
│   ├── local/
│   │   ├── local_storage.dart        // SharedPreferences wrapper
│   │   ├── products_cache.dart       // تخزين واسترجاع المواد محلياً
│   │   ├── areas_cache.dart          // تخزين المناطق محلياً
│   │   └── filters_storage.dart      // حفظ الفلاتر الافتراضية
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   ├── customer_model.dart
│   │   ├── invoice_model.dart
│   │   ├── return_model.dart
│   │   ├── receipt_model.dart
│   │   └── company_account_model.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── products_repository.dart
│       ├── customers_repository.dart
│       ├── transactions_repository.dart   // فواتير + مرتجعات + سندات معاً
│       └── company_accounts_repository.dart
│
├── logic/                            // Cubit فقط — لا Bloc Events
│   ├── auth/
│   │   ├── auth_cubit.dart
│   │   └── auth_state.dart
│   ├── dashboard/
│   │   ├── dashboard_cubit.dart
│   │   └── dashboard_state.dart
│   ├── transactions/
│   │   ├── transactions_cubit.dart
│   │   ├── transactions_state.dart
│   │   └── filters_model.dart        // نموذج الفلاتر
│   ├── customers/
│   │   ├── customers_cubit.dart
│   │   └── customers_state.dart
│   ├── company_accounts/
│   │   ├── company_accounts_cubit.dart
│   │   └── company_accounts_state.dart
│   └── admin/
│       ├── admin_cubit.dart
│       └── admin_state.dart
│
└── ui/
    ├── screens/
    │   ├── auth/
    │   │   └── login_screen.dart
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart
    │   ├── transactions/
    │   │   ├── transactions_screen.dart
    │   │   ├── invoice_form_screen.dart
    │   │   ├── return_form_screen.dart
    │   │   └── receipt_form_screen.dart
    │   ├── customers/
    │   │   ├── customers_screen.dart
    │   │   ├── customer_detail_screen.dart
    │   │   └── customer_form_screen.dart
    │   ├── company_accounts/
    │   │   └── company_accounts_screen.dart
    │   ├── settings/
    │   │   └── settings_screen.dart
    │   └── admin/
    │       ├── admin_screen.dart
    │       └── user_edit_screen.dart
    └── widgets/
        ├── common/
        │   ├── loading_widget.dart
        │   ├── error_widget.dart
        │   └── empty_state_widget.dart
        ├── transaction_card.dart         // يعرض لون مميز إذا is_synced: false
        ├── filter_panel.dart
        └── permission_guard.dart         // widget يخفي/يُظهر بناءً على الصلاحية
```

---

## ١٢. قواعد التنفيذ الإلزامية

هذه القواعد غير قابلة للتفاوض. أي انتهاك لها خطأ يجب تصحيحه.

### قواعد الكود

**١. لا Magic Strings أبداً**
```dart
// ❌ خطأ
firestore.collection('invoices').where('delegate_id', ...)

// ✅ صحيح
firestore.collection(FirestoreKeys.invoices).where(FirestoreKeys.delegateId, ...)
```
كل اسم collection وكل اسم حقل يجب أن يكون ثابتاً في `firestore_keys.dart`.

**٢. كل عملية تؤثر على رصيد أو كاش → داخل Firestore Transaction**
```dart
// ❌ خطأ — عمليتان منفصلتان قد تفشل إحداهما
await invoiceRef.set(invoiceData);
await customerRef.update({'balance': newBalance});

// ✅ صحيح — داخل Function على السيرفر فقط
// التطبيق يكتب الفاتورة فقط، والـ Function تتولى الباقي
```

**٣. التطبيق لا يحسب الأرصدة أبداً**
الأرصدة وحسابات الكاش مسؤولية Cloud Functions حصراً. التطبيق يقرأ ويعرض فقط.

**٤. فصل الطبقات صارم**
- UI لا تعرف عن Firestore — تتحدث مع Cubit فقط
- Cubit لا تعرف عن Firestore — تتحدث مع Repository فقط
- Repository هي الوحيدة التي تتحدث مع Firestore

**٥. الصلاحيات تُتحقق في موضعين**
- في UI: إخفاء/إظهار الأزرار عبر `PermissionGuard` widget
- في Security Rules: رفض الطلب على السيرفر

لا تعتمد على UI وحدها ولا على Rules وحدها.

**٦. المستخدم يرى فقط بياناته + can_monitor**
```dart
// هذا الـ query هو القاعدة في كل Collections
final delegateIds = [currentUser.uid, ...currentUser.canMonitor];
firestore.collection(FirestoreKeys.invoices)
  .where(FirestoreKeys.delegateId, whereIn: delegateIds)
```

**٧. warehouse_code و cost_center تُسحبان تلقائياً**
لا يُدخلهما المندوب يدوياً — تُقرآن من `currentUser.warehouseCode` و `currentUser.costCenterCode`.

**٨. كل Model له fromFirestore + toFirestore + copyWith**
```dart
class InvoiceModel {
  factory InvoiceModel.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
  InvoiceModel copyWith({ ... }) { ... }
}
```

**٩. لا setState في أي شاشة**
كل إدارة حالة عبر Cubit. الشاشات تعرض فقط.

**١٠. الـ Offline يعمل بشفافية تامة**
الكود لا يتحقق من الاتصال قبل أي عملية. Firestore يتولى الـ offline تلقائياً. الاستثناء الوحيد: عرض لون مميز للوثائق `is_synced: false`.

### قواعد Firebase

**١١. لا تكتب كلمة السر في Firestore أبداً**
كلمة السر في Firebase Auth فقط.

**١٢. تغيير الإيميل = تحديث Auth + Firestore معاً**
يتم عبر `adminUpdateUser` Function لضمان التزامن.

**١٣. تغيير كلمة السر يُلغي الجلسة فوراً**
يتم عبر `adminChangePassword` Function التي تستدعي `revokeRefreshTokens`.

**١٤. لا يُحذف أي document من products/ أبداً**
حتى المدير. Security Rule: `allow delete: if false`.

**١٥. daily_cash تكتب إليها Functions فقط**
Security Rule: `allow write: if false` في التطبيق.

### قواعد المنطق التجاري

**١٦. طرق الدفع: "cash" | "credit" فقط**
لا قيم أخرى. استخدم enum في Dart.

**١٧. الحقول الإلزامية للزبون: region + gender + اسم الزبون**
النموذج لا يُرسل حتى تُعبَّأ هذه الحقول.

**١٨. المندوب لا يرى ولا يتعامل إلا مع زبائنه**
في نموذج الفاتورة: قائمة الزبائن مفلترة بـ `delegate_id in [myUid, ...can_monitor]`.

**١٩. الرصيد السابق عند إنشاء الزبون**
يُكتب مباشرة كـ `balance` في Firestore. لا سند، لا Function، لا حركة.

**٢٠. الأرقام التسلسلية تبدأ من 1 بدون أصفار**
1، 2، 3 ... 10، 11 ... وليس 001، 002...

---

## ١٣. خطة التنفيذ المرحلية

### المرحلة الأولى — الأساس
1. إنشاء المشروع + pubspec.yaml + Firebase init + تفعيل Offline Persistence
2. `firestore_keys.dart` — كل الثوابت
3. Models كاملة (fromFirestore + toFirestore + copyWith)
4. AuthService + AuthRepository + AuthCubit
5. LoginScreen + التحقق من isActive

### المرحلة الثانية — البيانات الأساسية
6. ProductsRepository + ProductsCache (آلية products_version)
7. AreasCache (آلية areas_version)
8. CustomersRepository (جلب + إنشاء مع توليد الرمز والاسم + تعديل + حذف)

### المرحلة الثالثة — Cloud Functions
9. إعداد مشروع Functions (TypeScript)
10. adminCreateUser + adminUpdateUser + adminChangePassword + adminDeleteUser
11. onInvoiceCreate + onInvoiceUpdate + onInvoiceDelete (مع daily_cash logic)
12. onReturnCreate + onReturnUpdate + onReturnDelete
13. onReceiptCreate + onReceiptUpdate + onReceiptDelete

### المرحلة الرابعة — الشاشات
14. go_router — التنقل الكامل مع شرط الصلاحيات
15. Dashboard Screen
16. Transactions Screen — القائمة الموحدة + الفلاتر
17. شاشات إنشاء وتعديل الفاتورة والمرتجع والسند
18. Customers Screen + Customer Form
19. Company Accounts Screen
20. Settings Screen + Admin Screen + User Edit Screen

### المرحلة الخامسة — الميزات المتقدمة
21. تصدير Excel (المعاملات + الزبائن)
22. الطباعة — Rongta RPP300 WiFi ESC/POS (تصميم الفاتورة يُحدَّد لاحقاً)

---

**ابدأ دائماً من الخطوة 1 في المرحلة الأولى. لا تنتقل لمرحلة تالية قبل اكتمال السابقة.**
