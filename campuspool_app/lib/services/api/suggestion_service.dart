import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SuggestionService {
  // 서버 API 기본 URL (PostService 등과 동일하게 설정)
  // 예시: final String _authority = "10.0.2.2:8080";
  // 예시: final String _unencodedPathPrefix = "/api/suggestions";
  // 또는 baseUrl을 직접 사용
  final String _baseUrl = "http://10.0.2.2:8080/api/suggestions"; // 건의사항 API 엔드포인트

  Future<void> submitSuggestion({required String subject, required String content}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token'); // JWT 토큰 가져오기

    if (token == null) {
      // 실제 앱에서는 로그인 화면으로 보내거나 사용자에게 명확한 메시지를 보여주는 것이 좋습니다.
      throw Exception("로그인 정보가 없습니다. 다시 로그인해주세요. (submitSuggestion)");
    }

    final uri = Uri.parse(_baseUrl); // POST 요청은 기본 경로로
    final Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $token", // 헤더에 JWT 토큰 추가
    };
    final Map<String, String> body = {
      "subject": subject,
      "content": content,
    };

    print('[SuggestionService] Submitting suggestion. URL: $uri');
    print('[SuggestionService] Headers: $headers'); // 디버깅용 헤더 출력
    print('[SuggestionService] Body: ${jsonEncode(body)}'); // 디버깅용 본문 출력

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body), // 요청 본문을 JSON 문자열로 인코딩
    );

    if (response.statusCode == 200 || response.statusCode == 201) { // 성공 (201 Created도 고려)
      print('[SuggestionService] Suggestion submitted successfully. Status: ${response.statusCode}');
      // 성공 시 특별히 반환할 데이터가 없다면 void로 처리
    } else {
      // 서버에서 에러 메시지를 JSON 형태로 보낼 경우 파싱 시도
      String errorMessage = '건의사항 제출 실패 (Status: ${response.statusCode})';
      if (response.bodyBytes.isNotEmpty) {
        try {
          final decodedBody = utf8.decode(response.bodyBytes);
          // 서버 응답이 JSON 형태이고 'message' 필드가 있다면 사용
          final errorJson = jsonDecode(decodedBody);
          if (errorJson is Map && errorJson.containsKey('message')) {
            errorMessage += ': ${errorJson['message']}';
          } else {
            errorMessage += ': $decodedBody'; // JSON이 아니거나 message 필드가 없으면 전체 응답 본문 사용
          }
        } catch(e) { // JSON 파싱 실패 시
           errorMessage += ': ${utf8.decode(response.bodyBytes)}'; // 원본 응답 본문 사용
        }
      }
      print('[SuggestionService] $errorMessage');
      throw Exception(errorMessage); // 예외 발생시켜 UI에서 처리하도록 함
    }
  }
}