// lib/models/post.dart

import '../models/user.dart'; // ✅ 실제 User 모델의 경로로 수정해야 해!

class Post {
  final int id;
  final User user; // 게시물 작성자 (서버 응답에서 'user' 객체로 옴)
  final String date; // 서버에서 "yyyy-MM-dd" 형식의 문자열로 온다고 가정
  final String departure;
  final String destination;
  final String departureTime; // 서버에서 "HH:mm:ss" 형식의 문자열로 온다고 가정
  final String arrivalTime;   // 서버에서 "HH:mm:ss" 형식의 문자열로 온다고 가정
  final String fare;
  final String detail;
  final bool isDriver; // 서버 응답 JSON 키는 "driver"

  Post({
    required this.id,
    required this.user,
    required this.date,
    required this.departure,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.fare,
    required this.detail,
    required this.isDriver,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // 서버 응답 JSON의 실제 키 이름과 타입을 정확히 확인하고 매핑해야 함
    // Postman 응답을 기반으로 작성
    return Post(
      id: json['id'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>), // User.fromJson 구현 필요
      date: json['date'] as String,
      departure: json['departure'] as String,
      destination: json['destination'] as String,
      departureTime: json['departureTime'] as String,
      arrivalTime: json['arrivalTime'] as String,
      fare: json['fare'] as String, // 서버에서 문자열로 왔었음
      detail: json['detail'] as String,
      isDriver: json['driver'] as bool, // JSON 키는 "driver"
    );
  }
}