import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project_uas/screens/home_screen.dart';
import 'package:project_uas/screens/register_screen.dart';
import 'package:project_uas/screens/transaksi_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/homescreen': (context) => HomeScreen(),
        '/addExpense': (context) => TransactionScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
