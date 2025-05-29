class MessageModel {
  final String content;
  final String sender;
  final DateTime timestamp;
  final bool isMe;

  MessageModel({
    required this.content,
    required this.sender,
    required this.timestamp,
    required this.isMe,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String currentUser) {
    final sender = json['sender']?.toString() ?? 'unknown';
    final content = json['message']?.toString() ?? ''; // 서버에서는 'message'로 들어올 가능성
    final rawTimestamp = json['timestamp'];

    DateTime timestamp;
    if (rawTimestamp != null && rawTimestamp is String && rawTimestamp.isNotEmpty) {
      try {
        timestamp = DateTime.parse(rawTimestamp);
      } catch (_) {
        timestamp = DateTime.now();
      }
    } else {
      timestamp = DateTime.now();
    }

    return MessageModel(
      sender: sender,
      content: content,
      timestamp: timestamp,
      isMe: sender == currentUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}