import 'package:flutter/material.dart';
import '../../models/chat_room.dart';
import '../../services/api/chat_service.dart';
import 'chat_detail_screen.dart';
import 'package:campuspool_app/widgets/bottom_nav_bar.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  late Future<List<ChatRoom>> futureChatRooms;

  // 🔽 username 하드코딩 (나중에 로그인 연동 시 수정)
  final String currentUsername = "userA";

  @override
  void initState() {
    super.initState();
    futureChatRooms = ChatService().fetchChatRooms(currentUsername);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<ChatRoom>>(
        future: futureChatRooms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('채팅방이 없습니다.'));
          }

          final rooms = snapshot.data!;
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(room.profileImage),
                  radius: 24,
                ),
                title: Text(
                  room.opponentUsername,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(room.lastMessage),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        roomId: room.roomId,
                        opponentUsername: room.opponentUsername,
                        profileImage: room.profileImage,
                        nickname: room.nickname,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
