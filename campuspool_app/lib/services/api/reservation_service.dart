import 'dart:convert';
import '../../../models/reservation.dart'; // Reservation 모델 경로
import '../../../models/reservation_status.dart'; // ReservationStatus Enum 경로
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';



class ReservationService {
  // ✅ 실제 API 기본 URL로 변경해야 함
  final String _baseUrl = "http://10.0.2.2:8080/api/reservations"; // Android 에뮬레이터 기준

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // 1. 예약 상태 조회 API 호출
  Future<Reservation?> fetchReservationStatus(int postId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('토큰이 없습니다. 로그인이 필요합니다.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/status?postId=$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    debugPrint('[ReservationService] Fetch Status for postId $postId - Response Code: ${response.statusCode}');
    debugPrint('[ReservationService] Fetch Status Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      // 서버에서 "NOT_REQUESTED" 상태일 때 Reservation 객체 대신 Map<String, String>을 보냈었음
      // 이 부분을 확인하고, Reservation 객체로 파싱 가능한 경우에만 파싱
      if (body is Map<String, dynamic> && body.containsKey('id')) { // 'id' 필드가 있으면 Reservation 객체로 간주
        return Reservation.fromJson(body);
      } else if (body is Map<String, dynamic> && body['status'] == 'NOT_REQUESTED') {
        // 예약 정보가 없는 경우 (서버에서 NOT_REQUESTED 상태로 응답)
        // 여기서는 null을 반환하여 ChatDetailScreen에서 처리하도록 함
        // 또는 Reservation 객체에 postId와 status=NOT_REQUESTED만 담아서 반환할 수도 있음
        return null;
      } else {
        // 예상치 못한 응답 형식
        debugPrint('[ReservationService] Unexpected response format for fetchReservationStatus.');
        return null; // 또는 예외 발생
      }
    } else if (response.statusCode == 401) {
      throw Exception('인증 실패: 로그인이 필요합니다.');
    } else {
      throw Exception('예약 상태 조회 실패: ${response.statusCode}');
    }
  }

  // 2. 예약 요청 API 호출
  Future<Reservation> requestReservation(int postId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('토큰이 없습니다. 로그인이 필요합니다.');
    }

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'postId': postId}),
    );

    debugPrint('[ReservationService] Request Reservation for postId $postId - Response Code: ${response.statusCode}');
    debugPrint('[ReservationService] Request Reservation Response Body: ${response.body}');

    if (response.statusCode == 201) { // 생성 성공은 201 Created
      return Reservation.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 401) {
      throw Exception('인증 실패: 로그인이 필요합니다.');
    } else {
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      final errorMessage = errorBody['error'] ?? '예약 요청 실패';
      throw Exception('$errorMessage: ${response.statusCode}');
    }
  }

  // 3. 예약 수락 API 호출
  Future<Reservation> acceptReservation(int reservationId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('토큰이 없습니다. 로그인이 필요합니다.');
    }

    final response = await http.put( // PUT 메소드 사용
      Uri.parse('$_baseUrl/$reservationId/accept'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // PUT 요청 시 body는 필요 없을 수 있으나, API 명세에 따라 다름
      // body: jsonEncode({}), // 빈 body 또는 필요한 데이터
    );

    debugPrint('[ReservationService] Accept Reservation for reservationId $reservationId - Response Code: ${response.statusCode}');
    debugPrint('[ReservationService] Accept Reservation Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return Reservation.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 401) {
      throw Exception('인증 실패: 로그인이 필요합니다.');
    } else if (response.statusCode == 403) { // 권한 없음 (Forbidden)
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      final errorMessage = errorBody['error'] ?? '예약 수락 권한이 없습니다.';
      throw Exception(errorMessage);
    } else if (response.statusCode == 404) { // 리소스 없음 (Not Found)
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      final errorMessage = errorBody['error'] ?? '예약을 찾을 수 없습니다.';
      throw Exception(errorMessage);
    }
    else {
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      final errorMessage = errorBody['error'] ?? '예약 수락 실패';
      throw Exception('$errorMessage: ${response.statusCode}');
    }
  }

  // TODO: (선택 사항) 예약 거절 API 호출 메소드 (rejectReservation)
  // TODO: (선택 사항) 예약 취소 API 호출 메소드 (cancelReservation)
}