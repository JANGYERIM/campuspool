// 프로필 화면 구현 (닉네임 수정 버튼 토글 포함)
import 'package:campuspool_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import '../../../services/api/auth_api.dart'; // AuthApi 경로 확인
import 'package:shared_preferences/shared_preferences.dart';
import 'suggestion_screen.dart'; // 1. SuggestionScreen 임포트

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String nickname = 'yerimmi_'; // 기본값 또는 로딩 중 표시 텍스트
  bool isEditing = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNicknameFromServer();
  }

  Future<void> _loadNicknameFromServer() async {
    try {
      final profile = await AuthApi().getProfile(); // AuthApi().getProfile()이 Map<String, dynamic>을 반환한다고 가정
      final nicknameFromServer = profile['nickname'] as String?; // 타입 캐스팅 및 null 가능성 명시
      setState(() {
        nickname = nicknameFromServer ?? '익명'; // 서버 닉네임이 null이면 '익명'
        _controller.text = nickname;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', nickname); // 로컬에도 저장
    } catch (e) {
      print('서버에서 닉네임 로드 실패: $e');
      // 서버 실패 시 로컬 SharedPreferences에서 닉네임 로드 시도
      final prefs = await SharedPreferences.getInstance();
      final localNick = prefs.getString('nickname');
      setState(() {
        nickname = localNick ?? '익명'; // 로컬에도 없으면 '익명'
        _controller.text = nickname;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token'); // 특정 키만 제거하거나
    // await prefs.clear(); // 모든 데이터 제거 (선택)
    // 이메일 정보도 로그아웃 시 제거하는 것이 좋습니다.
    await prefs.remove('email');


    // Navigator.pushAndRemoveUntil을 사용하여 로그인 화면으로 이동하고 이전 스택 모두 제거
    if (mounted) { // 위젯이 여전히 마운트되어 있는지 확인
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _updateNickname() async {
    final newNickname = _controller.text.trim(); // 앞뒤 공백 제거
    if (newNickname.isEmpty) {
      // 닉네임이 비어있으면 사용자에게 알림 (선택 사항)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임은 비워둘 수 없습니다.')),
      );
      _controller.text = nickname; // 이전 닉네임으로 복원
      setState(() {
        isEditing = false; // 편집 모드 종료
      });
      return;
    }

    try {
      await AuthApi().updateProfile({'nickname': newNickname});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', newNickname);
      setState(() {
        nickname = newNickname;
        isEditing = false; // 편집 모드 종료
      });
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('닉네임이 변경되었습니다.')),
        );
      }
    } catch (e) {
      print('닉네임 업데이트 실패: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('닉네임 변경에 실패했습니다: $e')),
        );
      }
    }
  }

  void _toggleEdit() {
    if (isEditing) {
      // '변경' 버튼을 눌렀을 때 (편집 완료)
      _updateNickname();
    } else {
      // 'Nickname 수정' 버튼을 눌렀을 때 (편집 시작)
      _controller.text = nickname; // 현재 닉네임을 TextField에 설정
      setState(() {
        isEditing = true;
      });
    }
  }

  // 2. 함수 이름 변경 및 SuggestionScreen으로 이동하도록 수정
  void _goToSuggestionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SuggestionScreen()),
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
                // 실제 프로필 이미지가 있다면 여기에 표시
                // backgroundImage: NetworkImage('YOUR_PROFILE_IMAGE_URL'),
                backgroundColor: Colors.grey, // 기본 배경색
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              isEditing
                  ? Padding( // TextField 주변에 약간의 패딩 추가
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '닉네임 입력',
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                    )
                  : Text(
                      nickname,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _toggleEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEB5F5F), // 앱의 주요 색상
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  isEditing ? '닉네임 저장' : 'Nickname 수정', // 버튼 텍스트 변경
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _goToSuggestionScreen, // 수정된 함수 호출
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEB5F5F), // 건의하기 버튼 색상 (선택)
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('건의하기', style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700], // 로그아웃 버튼 색상 (선택)
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('로그아웃', style: TextStyle(fontSize: 14, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
