import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_with_nav.dart'; // 수정된 bottom nav 화면 import
import 'screens/post/post_list_screen.dart'; // 게시물 목록 화면 import
import 'screens/post/post_register_screen.dart'; // 게시물 등록 화면 import
import 'screens/reservation/reservation_list_screen.dart'; // 예약 목록 화면 import
import 'screens/message/message_list_screen.dart'; // 메시지 목록 화면 import
import 'screens/profile/profile_screen.dart'; // 프로필 화면 import


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '캠퍼스풀',
      theme: ThemeData(
        // 전체 폰트 통일
        fontFamily: 'NotoSansKR',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF303030)),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8C8C8C)),
        ),
      ),
      //home: const LoginScreen(), // 로그인 완료 시 HomeWithNav로 이동
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomeWithNav(), // 🏠 홈 화면 (게시물 목록 포함된 메인)
        '/login': (context) => const LoginScreen(),
        '/register': (context) => PostRegisterScreen(),
        '/posts': (context) => PostListScreen(),
      },
    );
  }
}
