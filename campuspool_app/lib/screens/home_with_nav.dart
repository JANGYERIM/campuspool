import 'package:flutter/material.dart';
import 'post/post_list_screen.dart';
// import 'reservation/reservation_list_screen.dart'; // ✅ 예약 화면 import 제거
import 'message/message_list_screen.dart';
import 'post/post_register_screen.dart';
import 'profile/profile_screen.dart';
import '../screens/message/chat_detail_screen.dart';

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
  Widget? _overrideScreen;

  final GlobalKey<PostRegisterScreenState> _registerKey =
      GlobalKey<PostRegisterScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      PostListScreen(onChatPressed: _openChatDetail),   // 인덱스 0: 조회
      // ReservationScreen(),                             // ✅ 예약 화면 제거
      PostRegisterScreen(key: _registerKey),         // 인덱스 1: 등록하기 (원래 2)
      MessageListScreen(onChatPressed: _openChatDetail),// 인덱스 2: 메시지 (원래 3)
      ProfileScreen(),                               // 인덱스 3: 프로필 (원래 4)
    ];
  }

  void _openChatDetail({
    required String roomId,
    required String profileImage,
    required String nickname,
    required String opponentUsername,
    required Map<String, dynamic> postData,
  }) {
    setState(() {
      _overrideScreen = ChatDetailScreen(
        roomId: roomId,
        profileImage: profileImage,
        nickname: nickname,
        opponentUsername: opponentUsername,
        postData: postData,
        onBack: () {
          setState(() {
            _overrideScreen = null;
          });
        },
      );
    });
  }

  Future<bool> _shouldNavigate(int newIndex) async {
    // ✅ 현재 등록하기 화면의 인덱스는 1 (0부터 시작하므로 _screens[1])
    if (_currentIndex == 1 && _screens[_currentIndex] is PostRegisterScreen) {
      final state = _registerKey.currentState;
      if (state != null && state.isDirty) {
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('등록 취소', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            content: const Text('등록을 취소하시겠습니까?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소', style: TextStyle(color: Colors.black))),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('확인', style: TextStyle(color: Color(0xFFEB5F5F)))),
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
      body: _overrideScreen ?? _screens[_currentIndex],
      bottomNavigationBar: _overrideScreen == null
          ? BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: _currentIndex,
              onTap: (index) async {
                if (index != _currentIndex) {
                  // ✅ _shouldNavigate 호출 시 현재 인덱스(_currentIndex)가 아닌,
                  //    이동하려는 새 인덱스(index)를 기준으로 판단하는 것이 아니라,
                  //    "현재 화면"이 등록하기 화면인지를 기준으로 판단해야 하므로,
                  //    _shouldNavigate 내부 로직에서 _currentIndex를 사용하도록 유지.
                  //    또는 _shouldNavigate 파라미터를 사용하지 않도록 수정.
                  //    여기서는 _shouldNavigate가 _currentIndex를 사용한다고 가정.
                  bool canNavigate = await _shouldNavigate(index); // index 파라미터는 _shouldNavigate 내부에서 사용 안 함
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
                BottomNavigationBarItem(icon: Icon(Icons.search), label: '조회'),       // 인덱스 0
                // "예약" 메뉴 아이템 삭제됨
                BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: '등록하기'), // 인덱스 1
                BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: '메시지'),   // 인덱스 2
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '프로필'),     // 인덱스 3
              ],
            )
          : null,
    );
  }
}