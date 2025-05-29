class ChatRoom {
  final String roomId;
  final String opponentUsername;
  final String lastMessage;
  final String profileImage;
  final String nickname;

  ChatRoom({
    required this.roomId,
    required this.opponentUsername,
    required this.lastMessage,
    required this.profileImage,
    required this.nickname,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      roomId: json['roomId'],
      opponentUsername: json['username'],
      lastMessage: json['lastMessage'],
      profileImage: json['profileImage'] ?? '',
      nickname: json['nickname'] ?? '익명',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'username': opponentUsername,
      'lastMessage': lastMessage,
      'profileImage': profileImage,
      'nickname': nickname,
    };
  }
}
