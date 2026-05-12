// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

// --- الثوابت والمسارات ---
import 'core/constants/app_routes.dart';

// --- الخدمات ---
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';

// --- قواعد البيانات المحلية والكاش ---
import 'data/local/app_database.dart';
import 'data/local/local_storage.dart';
import 'data/local/products_cache.dart';
import 'data/local/areas_cache.dart';

// --- المستودعات (Repositories) ---
import 'data/repositories/auth_repository.dart';
import 'data/repositories/products_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/transactions_repository.dart';
import 'data/repositories/customers_repository.dart';
import 'data/repositories/company_accounts_repository.dart';
import 'data/repositories/admin_repository.dart';

// --- النماذج (Models) ---
import 'data/models/user_model.dart';
import 'data/models/customer_model.dart';
import 'data/models/invoice_model.dart';
import 'data/models/return_model.dart';
import 'data/models/receipt_model.dart';
import 'data/models/unified_transaction.dart';
import 'data/models/product_model.dart';

// --- إدارة الحالة الأساسية ---
import 'logic/auth/auth_cubit.dart';
import 'logic/auth/auth_state.dart';
import 'logic/products_management/products_management_cubit.dart';

// --- الشاشات (Screens) ---
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/main_layout/main_layout.dart';
import 'ui/screens/settings/currency_history_screen.dart';
import 'ui/screens/transactions/invoice_form_screen.dart';
import 'ui/screens/transactions/return_form_screen.dart';
import 'ui/screens/transactions/receipt_form_screen.dart';
import 'ui/screens/transactions/transaction_details_screen.dart';
import 'ui/screens/customers/customer_form_screen.dart';
import 'ui/screens/admin/admin_screen.dart';
import 'ui/screens/admin/user_edit_screen.dart';
import 'ui/screens/settings/basic_info_screen.dart';
import 'ui/screens/products_management/products_management_screen.dart';
import 'ui/screens/products_management/product_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestoreService = FirestoreService();
  await firestoreService.enableNetworkAndPersistence();

  // تهيئة التخزين المحلي وقاعدة بيانات Drift
  final localStorage = await LocalStorage.init();
  final appDatabase = AppDatabase();
  final productsCache = ProductsCache(appDatabase, localStorage);
  final areasCache = AreasCache(localStorage);

  final authService = AuthService();

  final authRepository = AuthRepository(
    authService: authService,
    firestoreService: firestoreService,
  );

  final productsRepository = ProductsRepository(
    productsCache: productsCache,
    areasCache: areasCache,
  );

  final dashboardRepository = DashboardRepository();
  final transactionsRepository = TransactionsRepository();
  final customersRepository = CustomersRepository();
  final companyAccountsRepository = CompanyAccountsRepository();
  final adminRepository = AdminRepository();

  // الاستماع الحي لتحديثات المواد والمناطق وتحديث الكاش تلقائياً
  productsRepository.listenToVersionChanges();

  runApp(MyApp(
    authRepository: authRepository,
    productsRepository: productsRepository,
    dashboardRepository: dashboardRepository,
    transactionsRepository: transactionsRepository,
    customersRepository: customersRepository,
    companyAccountsRepository: companyAccountsRepository,
    adminRepository: adminRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ProductsRepository productsRepository;
  final DashboardRepository dashboardRepository;
  final TransactionsRepository transactionsRepository;
  final CustomersRepository customersRepository;
  final CompanyAccountsRepository companyAccountsRepository;
  final AdminRepository adminRepository;

  MyApp({
    Key? key,
    required this.authRepository,
    required this.productsRepository,
    required this.dashboardRepository,
    required this.transactionsRepository,
    required this.customersRepository,
    required this.companyAccountsRepository,
    required this.adminRepository,
  }) : super(key: key);

  late final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.login,
    routes:[
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.mainLayout,
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: AppRoutes.receiptForm,
        builder: (context, state) {
          final receiptDoc = state.extra as ReceiptModel?;
          return ReceiptFormScreen(receiptToEdit: receiptDoc);
        },
      ),
      GoRoute(
        path: AppRoutes.invoiceForm,
        builder: (context, state) {
          final invoice = state.extra as InvoiceModel?;
          return InvoiceFormScreen(invoiceToEdit: invoice);
        },
      ),
      GoRoute(
        path: AppRoutes.returnForm,
        builder: (context, state) {
          final returnDoc = state.extra as ReturnModel?;
          return ReturnFormScreen(returnToEdit: returnDoc);
        },
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: AppRoutes.userEdit,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final user = extra['user'] as UserModel?;
          final allUsers = extra['allUsers'] as List<UserModel>? ??[];
          return UserEditScreen(user: user, allUsers: allUsers);
        },
      ),
      GoRoute(
          path: AppRoutes.customerForm,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final target = extra['targetDelegateId'] as String?;
            final customer = extra['customer'] as CustomerModel?;
            final ownerSuffix = extra['ownerSuffix'] as String? ?? '';
            return CustomerFormScreen(
              customerToEdit: customer,
              targetDelegateId: target,
              ownerSuffix: ownerSuffix,
            );
          }
      ),
      GoRoute(
        path: AppRoutes.transactionDetails,
        builder: (context, state) {
          final transaction = state.extra as UnifiedTransaction;
          return TransactionDetailsScreen(transaction: transaction);
        },
      ),
      GoRoute(
        path: AppRoutes.basicInfo,
        builder: (context, state) => const BasicInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.productsManagement,
        builder: (context, state) => const ProductsManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.productForm,
        builder: (context, state) {
          final extra = state.extra;
          return BlocProvider(
            create: (context) => ProductsManagementCubit(context.read<ProductsRepository>()),
            child: Builder(
                builder: (ctx) {
                  if (extra is ProductModel) return ProductFormScreen(productToEdit: extra);
                  if (extra is Map<String, dynamic>) return ProductFormScreen(initialTab: extra['tab'], initialCol: extra['col'], initialRow: extra['row']);
                  return const ProductFormScreen();
                }
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.currencyHistory,
        builder: (context, state) => const CurrencyHistoryScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      if (authState is AuthUnauthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }
      if (authState is AuthAuthenticated && isLoggingIn) {
        return AppRoutes.mainLayout;
      }
      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers:[
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: productsRepository),
        RepositoryProvider.value(value: dashboardRepository),
        RepositoryProvider.value(value: transactionsRepository),
        RepositoryProvider.value(value: customersRepository),
        RepositoryProvider.value(value: companyAccountsRepository),
        RepositoryProvider.value(value: adminRepository),
      ],
      child: BlocProvider(
        create: (context) => AuthCubit(authRepository)..checkAuthStatus(),
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            _router.refresh();
          },
          child: MaterialApp.router(
            title: 'نظام توزيع البهارات',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const[
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const[
              Locale('ar', 'AE'),
            ],
            locale: const Locale('ar', 'AE'),
            theme: ThemeData(
              primarySwatch: Colors.teal,
              useMaterial3: true,
              fontFamily: 'Tajawal', // تأكد من إضافة الخط في pubspec.yaml لاحقاً
            ),
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}