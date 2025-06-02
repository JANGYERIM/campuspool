// lib/models/reservation.dart

import 'post.dart'; // ✅ 새로 만든 Post 모델 경로로 수정!
import 'user.dart';      // ✅ 실제 User 모델 경로로 수정!
import 'reservation_status.dart';

class Reservation {
  final int id;
  final Post post; // ✅ 타입을 Post로 변경
  final User requester;
  final User author;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reservation({
    required this.id,
    required this.post, // ✅ 타입 변경
    required this.requester,
    required this.author,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      post: Post.fromJson(json['post'] as Map<String, dynamic>), // ✅ Post.fromJson 사용
      requester: User.fromJson(json['requester'] as Map<String, dynamic>),
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      status: reservationStatusFromString(json['status'] as String? ?? 'NONE'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}