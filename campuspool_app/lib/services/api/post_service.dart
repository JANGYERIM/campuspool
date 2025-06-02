import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/post_summary.dart';
import 'package:flutter/material.dart';  // ✅ TimeOfDay 사용 가능해짐
import 'package:intl/intl.dart'; // ✅ DateFormat 사용 가능해짐
import 'package:shared_preferences/shared_preferences.dart';


  

class PostService {
  final String baseUrl = "http://10.0.2.2:8080/api/posts";

  Future<List<PostSummary>> fetchPosts({required bool isDriverTab, String keyword = ''}) async {
    final encodedKeyword = Uri.encodeQueryComponent(keyword);
    final uri = Uri.parse(
      '$baseUrl/by-role?viewerIsDriver=$isDriverTab&keyword=$encodedKeyword',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // ✅ utf8로 안전하게 디코딩
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((e) => PostSummary.fromJson(e)).toList();
    } else {
      throw Exception('게시물 불러오기 실패');
    }
  }

  Future<List<PostSummary>> searchPostsByKeyword({required String keyword}) async {
    if (keyword.trim().isEmpty) {
      return [];
    }

    // Uri.parse().replace()를 사용하여 기본 URL에 검색 경로와 쿼리 파라미터 추가
    final uri = Uri.parse('$baseUrl/search').replace(
      queryParameters: {'keyword': keyword}, // 쿼리 파라미터는 자동으로 인코딩됨
    );

    print('[PostService] Searching posts by keyword. URL: $uri');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      if (decodedBody.isEmpty) return [];
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((e) => PostSummary.fromJson(e)).toList();
    } else {
      print('[PostService] Failed to search posts by keyword. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('키워드 검색 실패 (Status: ${response.statusCode})');
    }
  }


  Future<Map<String, dynamic>> fetchPostById(String postId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$postId')); 
      print ('[PostService] Fetching post by ID. URL: $baseUrl/$postId');
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        throw Exception('게시글 정보 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('게시글 조회 오류: $e');
      throw Exception('게시글 정보를 불러오는 중 오류 발생');
    }
  }


  // ✅ 게시물 등록
  Future<void> createPost({
    required DateTime date,
    required String departure,
    required String destination,
    required TimeOfDay departureTime,
    required TimeOfDay arrivalTime,
    required String fare,
    required String detail,
    required bool isDriver,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception("로그인 정보가 없습니다. JWT 토큰이 없습니다.");
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final formattedDepartureTime =
        '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}:00';
    final formattedArrivalTime =
        '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}:00';

    final data = {
      "date": formattedDate,
      "departure": departure,
      "destination": destination,
      "departureTime": formattedDepartureTime,
      "arrivalTime": formattedArrivalTime,
      "fare": fare,
      "detail": detail,
      "driver": isDriver,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Authorization": "Bearer $token", // ✅ 인증 추가
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      final decoded = utf8.decode(response.bodyBytes);
      throw Exception('게시물 등록 실패: $decoded');
    }
  }
}