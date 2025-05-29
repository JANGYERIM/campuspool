import 'package:flutter/material.dart';
import 'post/post_list_screen.dart';
import 'reservation/reservation_list_screen.dart';
import 'message/message_list_screen.dart';
import 'post/post_register_screen.dart';
import 'profile/profile_screen.dart';

// ✅ 등록화면 dirty 상태 체크용 인터페이스
abstract class PostRegisterScreenStateInterface {
  bool get isDirty;
}

class HomeWithNav extends StatefulWidget {
  const HomeWithNav({super.key});

  @override
  State<HomeWithNav> createState() => _HomeWithNavState();
}

class _HomeWithNavState extends State<HomeWithNav> {
  int _currentIndex = 0;

  // ✅ 등록화면을 상태로 직접 관리
  final GlobalKey<PostRegisterScreenState> _registerKey =
      GlobalKey<PostRegisterScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      PostListScreen(),
      ReservationScreen(),
      PostRegisterScreen(key: _registerKey), // ✅ key를 이용해 state 접근 가능하게 함
      MessageListScreen(),
      ProfileScreen(),
    ];
  }
Future<bool> _shouldNavigate(int index) async {
  // ✅ 등록 화면일 경우에만 isDirty 확인
  if (_currentIndex == 2) {
    final state = _registerKey.currentState;
    if (state != null && state.isDirty) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white, // ✅ 흰 배경
          title: const Text(
            '등록 취소',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,),
          ),
          content: const Text(
            '등록을 취소하시겠습니까?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                '확인',
                style: TextStyle(color: Color(0xFFEB5F5F)), // ✅ 빨간 확인 버튼
              ),
            ),
          ],
        ),
      );
      return shouldLeave ?? false;
    }
  }
  return true;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index != _currentIndex) {
            bool canNavigate = await _shouldNavigate(index);
            if (canNavigate) {
              setState(() {
                _currentIndex = index;
              });
            }
          }
        },
        selectedItemColor: const Color(0xFFEB5F5F),
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '조회'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: '예약'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: '등록하기'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: '메시지'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '프로필'),
        ],
      ),
    );
  }
}
