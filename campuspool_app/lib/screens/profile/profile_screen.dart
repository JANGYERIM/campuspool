// 프로필 화면 구현 (닉네임 수정 버튼 토글 포함)
import 'package:campuspool_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import '../../../services/api/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String nickname = 'yerimmi_';
  bool isEditing = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNicknameFromServer();
  }

  Future<void> _loadNicknameFromServer() async {
    try {
      final profile = await AuthApi().getProfile();
      final nicknameFromServer = profile['nickname'];
      setState(() {
        nickname = nicknameFromServer ?? '익명';
        _controller.text = nickname;
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('nickname', nickname);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final localNick = prefs.getString('nickname');
      setState(() {
        nickname = localNick ?? '익명';
        _controller.text = nickname;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _updateNickname() async {
    final newNickname = _controller.text.isNotEmpty ? _controller.text : '익명';
    try {
      await AuthApi().updateProfile({'nickname': newNickname});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', newNickname);
      setState(() {
        nickname = newNickname;
        isEditing = false;
      });
    } catch (e) {
      print('닉네임 업데이트 실패: $e');
    }
  }

  void toggleEdit() {
    if (isEditing) {
      _updateNickname();
    } else {
      setState(() {
        isEditing = true;
      });
    }
  }

  void goToDeleteScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeletePostScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('프로필'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 44,
                child: Icon(Icons.person, size: 50, color: Colors.white),
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 16),
              isEditing
                  ? TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '닉네임 입력',
                      ),
                    )
                  : Text(
                      nickname,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: toggleEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: Text(
                  isEditing ? '변경' : 'Nickname 수정',
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: goToDeleteScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: const Text('게시물 삭제', style: TextStyle(fontSize: 13, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: const Text('로그아웃', style: TextStyle(fontSize: 13, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DeletePostScreen extends StatelessWidget {
  const DeletePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시물 삭제')),
      body: const Center(child: Text('게시물 삭제 기능 구현 예정')),
    );
  }
}
