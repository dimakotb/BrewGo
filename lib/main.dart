import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'ui/screens/splash_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/sign_up_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/cart_screen.dart';
import 'ui/screens/menu_screen.dart';
import 'ui/screens/payment_screen.dart';
import 'ui/screens/review_screen.dart';
import 'ui/screens/main_navigation.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/map_screen.dart';

import 'viewmodels/auth_vm.dart';
import 'viewmodels/home_vm.dart';
import 'viewmodels/menu_vm.dart';
import 'viewmodels/cart_vm.dart';
import 'viewmodels/payment_vm.dart';
import 'viewmodels/order_vm.dart';
import 'viewmodels/review_vm.dart';

import 'data/adapters/cart_item_adapter.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase 
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    
    debugPrint('Firebase initialization error: $e');
  } 

  // Initialize Mapbox
  try {
    MapboxOptions.setAccessToken(
      'pk.eyJ1IjoiZGltYXNvYmh5IiwiYSI6ImNtajR0bmp6OTFrc20zZHJ6MzZjN2J3b2UifQ.tQfqFyomOO-P88ZMINnEyA',
    );
    debugPrint('Mapbox initialized successfully');
  } catch (e) {
    debugPrint('Mapbox initialization error: $e');
  }

    // Initialize Hive
    try {
      await Hive.initFlutter();

      Hive.registerAdapter(CartItemAdapter());
      debugPrint('Hive initialized successfully');
    } catch (e) {
      debugPrint('Hive initialization error: $e');
    }

  runApp(const BrewgoApp());
}

class BrewgoApp extends StatelessWidget {
  const BrewgoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => MenuViewModel()),
        ChangeNotifierProvider(
          create: (_) {
            final cartVM = CartViewModel();
            cartVM.loadCart();
            return cartVM;
          },
        ),
        ChangeNotifierProvider(create: (_) => PaymentViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => ReviewViewModel()),
      ],
      child: MaterialApp(
        title: 'BrewGo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFA78971),
          fontFamily: 'Abril Fatface',
        ),
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/main': (context) => const MainNavigation(),
          '/home': (context) => const HomeScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/login': (context) => const LoginScreen(),
          '/cart': (context) => const CartScreen(),
          '/menu': (context) => const MenuScreen(),
          '/payment': (context) => const PaymentScreen(),
          '/review': (context) => const ReviewScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/map': (context) => const MapScreen(),
        },
      ),
    );
  }
}
