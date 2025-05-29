import 'package:flutter/material.dart';
import 'package:campuspool_app/models/message.dart';
import 'package:campuspool_app/services/api/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String currentUser;
  final String otherUser;

  const ChatScreen({
    Key? key,
    required this.roomId,
    required this.currentUser,
    required this.otherUser,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final List<MessageModel> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectToChat();
  }

  void _connectToChat() {
    _chatService.connectToRoom(
      roomId: widget.roomId,
      currentUser: widget.currentUser,
      onMessageReceived: (data) {
        setState(() {
          _messages.add(MessageModel.fromJson(data, widget.currentUser));
        });
      },
    );
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _chatService.fetchMessages(widget.roomId, widget.currentUser);
      setState(() {
        _messages.addAll(messages);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메시지를 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    _chatService.sendMessage(
      sender: widget.currentUser,
      receiver: widget.otherUser,
      message: _messageController.text.trim(),
    );

    _messageController.clear();
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];

                      return Align(
                        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: message.isMe ? Colors.blue : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: message.isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 