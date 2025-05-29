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
    return MessageModel(
      content: json['content'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
      isMe: json['sender'] == currentUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}