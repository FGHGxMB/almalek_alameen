// lib/main.dart

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
import 'logic/auth/auth_cubit.dart';
import 'logic/auth/auth_state.dart';
import 'ui/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تفعيل الكاش لـ Firestore (Offline Persistence)
  final firestoreService = FirestoreService();
  await firestoreService.enableNetworkAndPersistence();

  // حقن التبعيات (Dependency Injection اليدوي كما هو مطلوب)
  final authService = AuthService();
  final authRepository = AuthRepository(
    authService: authService,
    firestoreService: firestoreService,
  );

  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;

  MyApp({Key? key, required this.authRepository}) : super(key: key);

  // إعداد مسارات التطبيق عبر go_router
  late final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.login,
    routes:[
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('شاشة الـ Dashboard - قيد التنفيذ')),
        ),
      ),
    ],
    // حماية المسارات إذا لم يكن المستخدم مسجلاً
    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      if (authState is AuthUnauthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }
      if (authState is AuthAuthenticated && isLoggingIn) {
        return AppRoutes.dashboard;
      }
      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authRepository,
      child: BlocProvider(
        // جلب حالة الدخول بمجرد فتح التطبيق
        create: (context) => AuthCubit(authRepository)..checkAuthStatus(),
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            // تحديث الراوتر عند تغيير حالة الدخول
            _router.refresh();
          },
          child: MaterialApp.router(
            title: 'نظام توزيع البهارات',
            debugShowCheckedModeBanner: false,
            // دعم اللغة العربية والاتجاه من اليمين لليسار
            localizationsDelegates: const[
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'AE'), // Arabic
            ],
            locale: const Locale('ar', 'AE'),
            theme: ThemeData(
              primarySwatch: Colors.teal,
              useMaterial3: true,
              fontFamily: 'Tajawal', // يفضل إضافة خط عربي لاحقاً
            ),
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}