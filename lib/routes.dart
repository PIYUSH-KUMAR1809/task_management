import 'package:get/get.dart';
import 'package:task_management/auth/view/registration_screen.dart';
import 'package:task_management/splash_screen.dart';

import 'auth/view/login_screen.dart';
import 'home/view/home_screen.dart';

List<GetPage> get appRoutes => [
      GetPage(
        name: '/', // This will be the initial route
        page: () => const SplashScreen(),
      ),
      GetPage(
        name: '/login', // This will be the initial route
        page: () => const LoginScreen(),
      ),
      GetPage(
        name: '/signup',
        page: () => const RegistrationScreen(),
      ),
      GetPage(
        name: '/home',
        page: () => const HomeScreen(),
      ),
    ];
