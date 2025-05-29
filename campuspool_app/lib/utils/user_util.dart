import 'package:shared_preferences/shared_preferences.dart';


/// 현재 로그인된 사용자의 ID를 SharedPreferences에서 가져옵니다.
Future<String?> getLoginUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('currentUserId');
}
