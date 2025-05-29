import 'package:flutter/material.dart';
import '../../models/chat_room.dart';
import '../../services/api/chat_service.dart';
import 'chat_detail_screen.dart';
import 'package:campuspool_app/widgets/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  late Future<List<ChatRoom>> futureChatRooms;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      setState(() {
        currentUserId = userId;
        futureChatRooms = ChatService().fetchChatRooms(userId);
      });
    } else {
      setState(() {
        futureChatRooms = Future.error('유저 ID가 없습니다.');
      });
    }
  }

  Widget safeCircleAvatar(String? url) {
    if (url != null && url.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          url,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const CircleAvatar(
              radius: 24,
              child: Icon(Icons.person),
            );
          },
        ),
      );
    } else {
      return const CircleAvatar(
        radius: 24,
        child: Icon(Icons.person),
      );
    }
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
      body: currentUserId == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<ChatRoom>>(
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
                      isThreeLine: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: safeCircleAvatar(room.profileImage),
                      title: Text(
                        room.opponentUsername,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        room.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              roomId: room.roomId,
                              opponentUsername: room.opponentUsername,
                              profileImage: room.profileImage,
                              nickname: room.nickname,
                              postData: {
                                'date': '2025-00-00',
                                'departureTime': '00:00',
                                'arrivalTime': '00:00',
                                'departureLocation': '출발지',
                                'arrivalLocation': '도착지',
                                'fare': '0',
                              },
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
