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