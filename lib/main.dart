import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart'; // 홈 화면
import 'screens/login_screen.dart'; // 로그인 화면
import 'screens/signup_screen.dart'; // 회원가입 화면
import 'screens/sales_list_screen.dart'; // 판매 글 목록 화면
import 'screens/create_sale_screen.dart'; // 판매 글 작성 화면

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(), // 앱 시작 화면
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/salesList': (context) => const SalesListScreen(),
        '/createSale': (context) => const CreateSaleScreen(),
      },
    );
  }
}
