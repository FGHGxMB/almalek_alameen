# DEVELOPER HANDOVER LOG

## المبرمج الحالي: AI Agent 1 (تأسيس المشروع)
**تاريخ آخر تحديث:** بداية المرحلة الأولى.

### ماذا تم إنجازه في هذه الجلسة؟
1. فهم المتطلبات الجديدة من المستخدم (فصل Document IDs عن Display Codes لمنع الكوارث عند التعديل، وإضافة حقول `tab_name`, `column_index`, `row_index` لجدول المواد).
2. أمرت المستخدم بإنشاء مشروع Flutter وإضافة كل الحزم الضرورية في `pubspec.yaml` (Bloc, GoRouter, Firebase, Drift).
3. تمت كتابة وتجهيز ملف `lib/core/constants/firestore_keys.dart` وهو يحتوي الآن على كل الـ String Constants الخاصة بـ Firestore، مع تطبيق منطق الـ ID الجديد.
4. تم تحديث `PROJECT_CONTEXT.md` ليعكس القواعد الجديدة ليعتمد عليها أي AI قادم.

### أين توقفنا؟
أنهينا الخطوتين 1 و 2 من "المرحلة الأولى" المذكورة في الخطة. البنية التحتية الأساسية جاهزة، والحزم مثبتة، ومفاتيح Firestore جاهزة.

### إلى المبرمج القادم (Next AI):
مرحباً بك. لكي تكمل العمل بشكل صحيح:
1. اقرأ `PROJECT_CONTEXT.md` لتفهم القيود الصارمة والتحديثات.
2. يجب عليك الآن البدء بـ **الخطوة 3 من المرحلة الأولى**: إنشاء جميع الـ **Models** (User, Product, Customer, Invoice, Return, Receipt).
3. تذكر: Models يجب أن تحتوي على `fromFirestore` و `toFirestore` و `copyWith`.
4. تذكر جداً: الروابط بين النماذج تعتمد على `id` (Document ID) وليس الرموز (Codes).
5. بعد الـ Models، انتقل للـ Auth (Service, Repository, Cubit).
6. عندما تنهي عملك، قم بتحديث هذا الملف (`DEVELOPER_HANDOVER.md`) واكتب ما أنجزته وما يجب على من بعدك فعله.

####
---
---
---

## المبرمج الحالي: AI Agent 2 (إنشاء النماذج Data Models)
**تاريخ آخر تحديث:** إتمام الخطوة 3 من المرحلة الأولى.

### ماذا تم إنجازه في هذه الجلسة؟
1. قمت بقراءة التعليمات الصارمة وإنشاء كافة النماذج (Models) الخاصة بالمشروع داخل مجلد `lib/data/models/`.
2. النماذج التي أُنشئت: `user_model`, `product_model`, `customer_model`, `invoice_model`, `return_model`, `receipt_model`, `company_account_model`, بالإضافة إلى `transaction_item_model` للاستخدام المشترك.
3. تم تطبيق قاعدة "الاعتماد على Document IDs كمعرفات أساسية للروابط" حرفياً.
4. تم استخدام `FirestoreKeys` من مجلد الـ constants في كل النماذج دون استخدام أي Magic Strings.
5. كل كلاس يحتوي على `fromFirestore` و `toFirestore` و `copyWith` ويتعامل مع `Timestamp` الخاص بـ Firebase بشكل سليم.

### أين توقفنا؟
أنهينا "الخطوة 3 من المرحلة الأولى". قاعدة النماذج متينة ومكتملة تماماً وتلبي كل المتطلبات.

### إلى المبرمج القادم (Next AI):
مرحباً بك. لكي تكمل العمل:
1. اقرأ `PROJECT_CONTEXT.md` لتفهم القيود المعمارية للمشروع.
2. يجب عليك الآن البدء بـ **الخطوات 4 و 5 من المرحلة الأولى**:
    - إنشاء نظام المصادقة `AuthService` في طبقة الـ services.
    - إنشاء `AuthRepository`.
    - إنشاء `AuthCubit` وإعداد الحالات `AuthState`.
    - إعداد شاشة `LoginScreen` والتحقق من حالة المستخدم (`isActive`).
3. انتبه: نظامنا لا يوجد فيه "تسجيل حساب" أو "نسيت كلمة المرور" من الواجهة. تسجيل الدخول فقط بالإيميل وكلمة السر.
4. بعد الانتهاء، قم بتحديث ملف الـ `DEVELOPER_HANDOVER.md`.

####
---
---
---

## المبرمج الحالي: AI Agent 3 (المصادقة وربط الواجهات)
**تاريخ آخر تحديث:** إتمام المرحلة الأولى بالكامل.

### ماذا تم إنجازه في هذه الجلسة؟
1. إنشاء خدمات Firebase الأساسية: `AuthService` و `FirestoreService` (مع تفعيل `Offline Persistence`).
2. إنشاء `AuthRepository` لتسجيل الدخول والتحقق الإلزامي من وجود حساب نشط (`isActive: true`) داخل `Firestore`.
3. إعداد الـ State Management للمصادقة عبر `AuthCubit` و `AuthState`.
4. تصميم واجهة `LoginScreen` باستخدام `flutter_bloc` لعرض التنبيهات وإظهار شريط تحميل وتوجيه المستخدم.
5. كتابة `main.dart` بشكل كامل وإعداد الـ Routing باستخدام `go_router` مع نظام حماية المسارات (Route Guards) لدعم اللغة العربية وتوجيه غير المصرح لهم إلى تسجيل الدخول.

### أين توقفنا؟
أنهينا "المرحلة الأولى بالكامل". التطبيق الآن قابل للتشغيل ويمكنه تسجيل دخول المندوب أو رفضه إذا كان موقوفاً.

### إلى المبرمج القادم (Next AI):
مرحباً بك. لكي تكمل العمل:
1. اقرأ `PROJECT_CONTEXT.md` للاطلاع على آلية تحميل وتخزين المواد (Products) والمناطق (Areas).
2. يجب عليك الآن البدء بـ **الخطوة 6 و 7 من المرحلة الثانية**:
    - إعداد قاعدة البيانات المحلية `Drift` لتخزين المواد وحفظها.
    - إنشاء `ProductsCache` و `AreasCache` (مخازن SharedPreferences للأرقام التسلسلية والإصدارات `version`).
    - إنشاء `ProductsRepository` الذي يُطبق قاعدة: "اقرأ إصدار المواد، قارنه بالمحلي، حمّل من السيرفر فقط إذا اختلفا، احفظ في Drift، حدّث الإصدار".
3. تأكد من أن `Drift` يستخدم الـ Models المعتمدة والموجودة لدينا سابقاً أو يقوم بالتحويل بينها.
4. بعد الانتهاء، قم بتحديث ملف `DEVELOPER_HANDOVER.md`.

####
---
---
---

## المبرمج الحالي: AI Agent 4 (إنشاء نظام التخزين المحلي Drift للكاش)
**تاريخ آخر تحديث:** إتمام الخطوتين 6 و 7 من المرحلة الثانية.

### ماذا تم إنجازه في هذه الجلسة؟
1. بناء جدول المواد `ProductsTable` داخل قاعدة بيانات `Drift` (SQLite) لتمكين العرض المحلي دون إنترنت.
2. استخدام الـ `build_runner` لتوليد ملف `app_database.g.dart` بنجاح.
3. دمج `SharedPreferences` كمخزن لإصدارات التحديثات عبر كلاس `LocalStorage`.
4. تصميم فئتي `ProductsCache` و `AreasCache` للتعامل مع حفظ وجلب البيانات محلياً.
5. كتابة `ProductsRepository` مع الدالة الجوهرية `syncProductsAndAreas` التي تطبق القواعد الحرفية: (اقرأ الإصدار -> قارنه -> حمّل إذا تغيّر -> احفظ محلياً).
6. حقن جميع الـ Services الجديدة داخل `main.dart` واستدعاء الـ sync في الخفاء عند فتح التطبيق.

### أين توقفنا؟
أنهينا إعدادات التخزين المحلي والمزامنة التلقائية. البنية التحتية للمواد والمناطق باتت جاهزة ومتصلة بنجاح مع Firestore كـ Single Source of Truth.

### إلى المبرمج القادم (Next AI):
مرحباً بك. لكي تكمل العمل:
1. اقرأ `PROJECT_CONTEXT.md` خصوصاً قسم آلية بناء الزبائن والأرقام التسلسلية.
2. يجب عليك الآن تنفيذ **الخطوة 8 من المرحلة الثانية**:
    - بناء `account_code_generator.dart` (Utility لبناء رمز الزبون `mainCustomerAccount + counter`).
    - بناء `customer_name_builder.dart` (Utility لبناء اسم الزبون `suffix + name + region`).
    - إنشاء `CustomersRepository` شامل، ويجب أن يطبق فلترة `whereIn:[myUid, ...can_monitor]`.
    - عند إضافة الزبون (`createCustomer`)، تذكر أن الرصيد الافتتاحي يُسجل كـ `balance` مباشرة دون أي Function إضافية.
3. بعد الانتهاء، قم بتحديث ملف `DEVELOPER_HANDOVER.md`.

####
---
---
---

# DEVELOPER HANDOVER LOG

## المبرمج الحالي: AI Agent 5 (نظام الزبائن وإكمال المرحلة الثانية)
**تاريخ آخر تحديث:** إتمام المرحلة الثانية بالكامل.

### ماذا تم إنجازه في هذه الجلسة؟
1. بناء أداة `AccountCodeGenerator` لدمج `main_customer_account` مع `customer_counter` لإنشاء كود الزبون.
2. بناء أداة `CustomerNameBuilder` لدمج `customer_suffix` مع اسم الزبون ومنطقته بطريقة نظيفة وموحدة.
3. إنشاء `CustomersRepository` الذي يتضمن:
    - الاستعلام عن الزبائن باستخدام `Stream` مع فلترة دقيقة: `whereIn: [currentUser.id, ...currentUser.canMonitor]`.
    - إضافة الزبائن الجدد بشكل آمن عبر `Firestore Transaction` لتحديث `customer_counter` في ملف المندوب، وقراءة الإعدادات العامة للمدينة والبلد، وتحديد الـ `balance` بقيمة الـ `previousBalance` مباشرة عند الإنشاء دون أي حركات إضافية.

### أين توقفنا؟
أنهينا "المرحلة الثانية بالكامل". التطبيق الآن قادر على المصادقة، تحميل المواد والمناطق وتخزينها محلياً، وجلب/إنشاء الزبائن بقواعد البيانات الصارمة.

### إلى المبرمج القادم (Next AI):
مرحباً بك. لقد وصلنا إلى **المرحلة الثالثة: Cloud Functions (الباكند)**. لكي تكمل العمل:
1. اقرأ `PROJECT_CONTEXT.md` وتحديداً القسم 7 (Cloud Functions الكاملة TypeScript).
2. يجب عليك إرشاد المطور لتهيئة بيئة `Firebase Functions` باستخدام TypeScript.
3. كتابة دوال `Auth` للإدارة: `adminCreateUser`, `adminUpdateUser`, `adminChangePassword`, `adminDeleteUser`.
4. كتابة دوال الـ Triggers (Transactions) الخاصة بـ `Invoices`, `Returns`, `Receipts` للتأثير المباشر على أرصدة الزبائن وكاش اليوم (`daily_cash/{date}`).
5. بعد الانتهاء من كتابة الدوال، قم بتحديث ملف `DEVELOPER_HANDOVER.md`.