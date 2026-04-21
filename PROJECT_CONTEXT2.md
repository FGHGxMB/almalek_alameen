# PROJECT CONTEXT — تطبيق إدارة مندوبي توزيع البهارات
*(تم التحديث: الاعتماد على IDs الفريدة بدلاً من Codes، وإضافة هندسة عرض المواد)*

## ١. هوية النموذج ودوره
أنت مهندس برمجيات أول متخصص في Flutter وFirebase. دورك الإشراف على التنفيذ، كتابة كود كامل جاهز للتشغيل بدون اختصارات، والالتزام بهذا السياق حرفياً. لا تضف مكاتب خارجية لم تُذكر هنا. التطبيق مخصص للـ Android فقط كأداة داخلية.

## ٢. التحديثات الجوهرية (مهم جداً)
- **المعرفات (IDs) ضد الرموز (Codes):** كل المجموعات (الزبائن، المواد، الفواتير) تمتلك `Document ID` فريد يُستخدم في الـ Relations البرمجية (مثل `customer_id` داخل الفاتورة). الرموز مثل `account_code` و `item_code` هي حقول قابلة للتعديل وتستخدم للعرض وللمستخدم فقط.
- **هندسة واجهة المواد:** المواد تُعرض كشبكة. كل مادة تحتوي على `tab_name` (اسم التبويب/المجموعة في الأعلى)، `column_index` (رقم العمود)، و `row_index` (ترتيبها في العمود).

## ٣. التقنيات المعتمدة
- **الواجهة:** Flutter (Android Only), Dart, go_router, google_fonts.
- **إدارة الحالة:** flutter_bloc (Cubit حصراً). لا Provider ولا GetX.
- **قاعدة البيانات:** Firebase Firestore و Drift (SQLite) للتخزين المحلي.
- **الباكند:** Firebase Auth و Cloud Functions (TypeScript). لا يوجد API خارجي.
- **التخزين المحلي:** shared_preferences للإعدادات، Drift للكاش المعقد.

## ٤. بنية Firestore
- **`settings/app_config`:** إعدادات عامة ثابتة.
- **`users/{uid}`:** بيانات المندوب + صلاحيات `permissions` + قائمة `can_monitor`.
- **`products/{id}`:** تحتوي على `item_code`, `tab_name`, `column_index`, `row_index`.
- **`customers/{id}`:** تحتوي على `account_code`, `delegate_id`, `balance`.
- **`invoices/{id}`:** تحتوي على `customer_id`, `items` (التي بداخلها `product_id`).
- (المرتجعات والسندات تتبع نفس نمط استخدام الـ IDs).

## ٥. قواعد التنفيذ الإلزامية
1. **لا Magic Strings:** استخدم `FirestoreKeys` دائماً.
2. **فصل الطبقات:** UI -> Cubit -> Repository -> Firestore/Drift.
3. **التزامن والأرصدة:** Cloud Functions هي المسؤولة الوحيدة عن حساب وتعديل الأرصدة و `daily_cash` عبر Transactions. التطبيق يكتب الفاتورة فقط.
4. **العرض الآمن:** أي استعلام يتم مفلتراً بـ `whereIn: [myUid, ...can_monitor]`.

####
---
---
---

# PROJECT CONTEXT — تطبيق إدارة مندوبي توزيع البهارات
*(التحديث الأخير: الاستغناء الكامل عن Cloud Functions واستخدام WriteBatch)*

## ١. هوية النموذج ودوره
أنت مهندس برمجيات أول متخصص في Flutter وFirebase. التطبيق مخصص للـ Android فقط كأداة داخلية.

## ٢. التحديثات الجوهرية (مهم جداً)
- **لا Cloud Functions:** تم الاستغناء عنها تماماً (Spark Plan). جميع الحسابات المعقدة (الكاش اليومي، الأرصدة، العدادات) تتم داخل التطبيق باستخدام `WriteBatch` و `FieldValue.increment` لضمان التزامن وعملها في وضع الـ Offline.
- **إدارة المستخدمين من التطبيق:** إنشاء المستخدمين يتم عبر تهيئة تطبيق `FirebaseApp` ثانوي داخل الكود لمنع تسجيل خروج المدير الحالي.

## ٣. التقنيات المعتمدة
Flutter, Dart, go_router, flutter_bloc (Cubit), Firebase Auth, Cloud Firestore, Drift (SQLite), SharedPreferences.

## ٤. آليات العمل الجديدة (Batch Writes)
عند إنشاء فاتورة، يقوم التطبيق بما يلي في `WriteBatch` واحد:
1. إضافة وثيقة الفاتورة في `invoices`.
2. زيادة `invoice_counter` العام في `settings/app_config`.
3. زيادة `delegate_invoice_counter` في `users/{uid}`.
4. تحديث الكاش في `users/{uid}/daily_cash/{date}` أو تحديث رصيد الزبون في `customers/{id}` باستخدام `FieldValue.increment`.

## ٥. قواعد التنفيذ الإلزامية
1. لا Magic Strings: استخدم `FirestoreKeys` دائماً.
2. فصل الطبقات صارم.
3. العرض الآمن: الفلترة دائماً بـ `whereIn: [myUid, ...can_monitor]`.
4. أي عملية مالية (إنشاء/تعديل/حذف معاملة) يجب أن تمر عبر `TransactionsRepository` لتنفيذ الـ Batch والتأكد من سلامة البيانات المالية.