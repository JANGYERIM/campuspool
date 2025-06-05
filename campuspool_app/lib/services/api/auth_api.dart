import '../../models/user.dart';
import '../../utils/constants.dart';
import 'api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {
  final ApiClient _apiClient = ApiClient();
  
  // 로그인
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final token = response.data['token'];
      final userId = response.data['userId'];
      if (token != null && userId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setString('currentUserId', userId);
        await prefs.setString('email', email); // 이메일 정보 저장];
        print('Saved email to SharedPreferences: $email');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('로그인 실패: $e');
      return false;
      }
  }
  
  
  // 회원가입
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('회원가입 실패: $e');
      return false;
    }
  }
  
  // 프로필 조회
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);
      return response.data;
    } catch (e) {
      print('프로필 조회 예외 실패: $e');
      rethrow;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
    } catch (e) {
      print('로그아웃 실패: $e');
    }
  }

  // 유저 정보 수정 (닉네임 포함)
Future<void> updateProfile(Map<String, dynamic> data) async {
  try {
    final response = await _apiClient.put(ApiConstants.profileUpdate, data: data);
    if (response.statusCode != 200) {
      throw Exception('프로필 업데이트 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('프로필 업데이트 예외 발생: $e');
    rethrow;
  }
}


}