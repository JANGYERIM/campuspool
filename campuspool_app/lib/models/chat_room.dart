import 'reservation_status.dart';

class ChatRoom {
  final String roomId;
  final String opponentUsername;
  final String lastMessage;
  final String profileImage;
  final String nickname;
  final String? postId;
  final ReservationStatus reservationStatus;
  final String currentUserRoleInReservation; // "REQUESTER", "AUTHOR", "NONE"

  ChatRoom({
    required this.roomId,
    required this.opponentUsername,
    required this.lastMessage,
    required this.profileImage,
    required this.nickname,
    this.postId,
    required this.reservationStatus,
    required this.currentUserRoleInReservation,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    print("[ChatRoom] fromJson Input JSON: $json");


    return ChatRoom(
      roomId: json['roomId'] as String,
      opponentUsername: json['opponentUsername'] as String,
      lastMessage: json['lastMessage'] as String,
      profileImage: json['profileImage'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '익명',
      postId: json['postId'] as String?,
      reservationStatus: reservationStatusFromString(json['reservationStatus'] as String? ?? 'NONE'),
      currentUserRoleInReservation: json['currentUserRoleInReservation'] as String? ?? 'NONE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'username': opponentUsername,
      'lastMessage': lastMessage,
      'profileImage': profileImage,
      'nickname': nickname,
      'postId': postId,
      'reservationStatus': reservationStatus.name, // Enum 값을 문자열로 변환 (예: "REQUESTED")
      'currentUserRoleInReservation': currentUserRoleInReservation,
    };
  }
}
