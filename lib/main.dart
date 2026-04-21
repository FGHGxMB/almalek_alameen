// lib/main.dart

import 'package:spice_app/ui/screens/transactions/invoice_form_screen.dart';

import 'data/repositories/admin_repository.dart';
import 'ui/screens/admin/admin_screen.dart';
import 'ui/screens/admin/user_edit_screen.dart';
import 'data/models/user_model.dart'; // نحتاجها لاحقاً للـ extra
import 'data/repositories/company_accounts_repository.dart';
import 'ui/screens/customers/customer_form_screen.dart';
import 'ui/screens/transactions/return_form_screen.dart';
import 'data/repositories/customers_repository.dart';
import 'ui/screens/transactions/receipt_form_screen.dart';
import 'data/repositories/transactions_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'ui/screens/main_layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

import 'core/constants/app_routes.dart';
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/products_repository.dart';
import 'data/local/app_database.dart';
import 'data/local/local_storage.dart';
import 'data/local/products_cache.dart';
import 'data/local/areas_cache.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/auth/auth_state.dart';
import 'ui/screens/auth/login_screen.dart';

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

  // تحديث المواد والمناطق فور فتح التطبيق بالخفاء
  productsRepository.syncProductsAndAreas();

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
        builder: (context, state) => const ReceiptFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.invoiceForm,
        builder: (context, state) => const InvoiceFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.returnForm,
        builder: (context, state) => const ReturnFormScreen(), // <--- تم تفعيل الشاشة الحقيقية
      ),
      GoRoute(
        path: AppRoutes.customerForm,
        builder: (context, state) => const CustomerFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminScreen(), // <--- شاشة الأدمن الحقيقية
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
    ],
    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      // إذا لم يسجل دخول ولا يحاول تسجيل الدخول -> اذهب للـ login
      if (authState is AuthUnauthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }
      // إذا مسجل دخول ويحاول فتح شاشة الـ login -> اذهب للـ mainLayout
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
              fontFamily: 'Tajawal',
            ),
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}