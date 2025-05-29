import 'package:campuspool_app/utils/user_util.dart';
import 'package:flutter/material.dart';
import '../../models/message.dart'; // 채팅 메시지 모델
import '../../services/api/chat_service.dart'; // API 연동용 서비스
import '../message/message_list_screen.dart'; // 메시지 목록 화면

class ChatDetailScreen extends StatefulWidget {
  final String roomId;
  final String profileImage;
  final String nickname;
  final String opponentUsername;
  final Map<String, dynamic> postData;

  const ChatDetailScreen({
    Key? key,
    required this.roomId,
    required this.profileImage,
    required this.nickname,
    required this.opponentUsername,
    required this.postData,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  Future<List<MessageModel>>? _messages;
  final TextEditingController _messageController = TextEditingController();
  final ChatService chatService = ChatService();
  String? currentUser;

  @override
  void initState() {
    super.initState();
    initChat();
  }

  void initChat() async {
    currentUser = await getLoginUserId();
    if (currentUser == null) {
      // 로그인되지 않은 경우 처리
      print('로그인되지 않은 사용자입니다.');
      Navigator.pop(context);
      return;
    }
    print('현재 사용자: $currentUser');

    setState(() {
      _messages = chatService.fetchMessages(widget.roomId, currentUser!);
    });

    // WebSocket 연결 및 구독
  chatService.connectToRoom(
    roomId: widget.roomId,
    currentUser: currentUser!,
    onMessageReceived: (data) {
      setState(() {
        _messages = chatService.fetchMessages(widget.roomId, currentUser!);
      });
    },
  );
}
  
  @override
  void dispose() {
    chatService.disconnect();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    chatService.sendMessage(
      sender: currentUser!,
      receiver: widget.opponentUsername,
      message: text,
    );

    _messageController.clear();
  }

  Widget _buildMessage(MessageModel msg) {
    final isMine = msg.isMe;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFFEB5F5F) : const Color(0xFF8C8C8C),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(msg.isMe ? 15 : 0),
            bottomRight: Radius.circular(msg.isMe ? 0 : 15),
          ),
        ),
        child: Text(
          msg.content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTripInfo() {
    final data = widget.postData;
    final String date = data['date'] ?? '';
    final String departureTime = data['departureTime'] ?? '';
    final String arrivalTime = data['arrivalTime'] ?? '';
    final String departure = data['departure'] ?? '';
    final String destination = data['destination'] ?? '';
    final String fare = data['fare'] != null ? '${data['fare']}원' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFF8C8C8C)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('탑승 일시: $date', style: tripTextStyle),
              SizedBox(height: 4),
              Text('출발: $departureTime  도착: $arrivalTime', style: tripTextStyle),
              SizedBox(height: 4),
              Text('출발지: $departure  /  도착지: $destination', style: tripTextStyle),
              SizedBox(height: 4),
              Text('요금: $fare', style: tripTextStyle),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ReservationButton(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MessageListScreen()),
            (route) => false,
            );
          }
        ),
        title: Text(widget.nickname,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: Column(
        children: [
          _buildTripInfo(),
          const SizedBox(height: 8),
          Expanded(
            child: _messages ==null
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<List<MessageModel>>(
              future: _messages,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final msgs = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: msgs.length,
                    itemBuilder: (context, index) {
                      final msg = msgs[index];
                      bool showDate = index == 0 ||
                          msg.timestamp.day != msgs[index - 1].timestamp.day;
                      return Column(
                        children: [
                          if (showDate)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                _formatDate(msg.timestamp),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          _buildMessage(msg),
                        ],
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('오류: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildInputBox(),
        ],
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F7FA),
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요',
                hintStyle: TextStyle(color: Color(0xFF9D9FA0)),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: _sendMessage,
            child: const Icon(Icons.send, color: Color(0xFFEB5F5F)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)}';
  }

  String _twoDigits(int n) => n < 10 ? '0$n' : '$n';
}

const tripTextStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w500,
  color: Colors.black87,
);

class ReservationButton extends StatelessWidget {
  const ReservationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/reservation');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEB5F5F),
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3FEC5F5F),
              blurRadius: 14,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: const Text(
          '예약 요청',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}