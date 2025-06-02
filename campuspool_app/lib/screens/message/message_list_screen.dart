import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/chat_room.dart';
import '../../services/api/chat_service.dart';
import '../../services/api/post_service.dart';
import '../../models/reservation_status.dart'; // ✅ ReservationStatus Enum 경로 확인 및 import!

class MessageListScreen extends StatefulWidget {
  final void Function({
    required String roomId,
    required String profileImage,
    required String nickname,
    required String opponentUsername,
    required Map<String, dynamic> postData,
  })? onChatPressed;

  const MessageListScreen({super.key, this.onChatPressed});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  Future<List<ChatRoom>>? _chatRoomsFuture;
  final ChatService _chatService = ChatService();
  final PostService _postService = PostService();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    debugPrint("[MessageListScreen] initState called");
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    debugPrint("[MessageListScreen] _initializeUser called");
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('currentUserId');
    debugPrint("[MessageListScreen] currentUserId from SharedPreferences: $userId");

    if (userId == null || userId.isEmpty) {
      debugPrint("[MessageListScreen] User not logged in.");
      if (mounted) {
        setState(() {
          _chatRoomsFuture = Future.error('로그인이 필요합니다.');
        });
      }
    } else {
      debugPrint("[MessageListScreen] User logged in: $userId. Fetching chat rooms.");
      if (mounted) {
        setState(() {
          currentUserId = userId;
          _chatRoomsFuture = _chatService.fetchChatRooms(userId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[MessageListScreen] build called. currentUserId: $currentUserId, _chatRoomsFuture: $_chatRoomsFuture");
    return Scaffold(
      appBar: AppBar(
        title: const Text("메시지함"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: currentUserId == null && _chatRoomsFuture == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("사용자 정보 로딩 중..."),
                ],
              ),
            )
          : FutureBuilder<List<ChatRoom>>(
              future: _chatRoomsFuture,
              builder: (context, snapshot) {
                debugPrint("[MessageListScreen] FutureBuilder: connectionState=${snapshot.connectionState}, hasError=${snapshot.hasError}, hasData=${snapshot.hasData}");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  debugPrint("[MessageListScreen] FutureBuilder error: ${snapshot.error}");
                  return Center(child: Text('오류 발생: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  debugPrint("[MessageListScreen] FutureBuilder: No chat rooms found.");
                  return const Center(child: Text('채팅방이 없습니다.'));
                }

                final chatRooms = snapshot.data!;
                debugPrint("[MessageListScreen] FutureBuilder: Found ${chatRooms.length} chat rooms.");
                return ListView.builder(
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = chatRooms[index];
                    debugPrint("[MessageListScreen] ListView item $index: roomId=${room.roomId}, nickname=${room.nickname}, postId=${room.postId}, reservationStatus=${room.reservationStatus.name}, currentUserRoleInReservation=${room.currentUserRoleInReservation}");

                    // --- 예약 상태에 따른 아이콘 결정 로직 ---
                    Widget? displayIcon; // ✅ 변수명 displayIcon으로 통일

                    switch (room.reservationStatus) {
                      case ReservationStatus.REQUESTED:
                        if (room.currentUserRoleInReservation == "REQUESTER") {
                          displayIcon = const Icon(Icons.outbond_outlined, color: Colors.orangeAccent, size: 20);
                        } else if (room.currentUserRoleInReservation == "AUTHOR") {
                          displayIcon = const Icon(Icons.notifications_active_outlined, color: Colors.redAccent, size: 20);
                        }
                        break;
                      case ReservationStatus.ACCEPTED:
                        displayIcon = const Icon(Icons.check_circle_outline, color: Colors.green, size: 20);
                        break;
                      case ReservationStatus.REJECTED:
                        displayIcon = const Icon(Icons.cancel_outlined, color: Colors.red, size: 20);
                        break;
                      case ReservationStatus.CANCELLED:
                        displayIcon = const Icon(Icons.do_not_disturb_on_outlined, color: Colors.grey, size: 20);
                        break;
                      case ReservationStatus.NONE:
                      case ReservationStatus.UNKNOWN:
                      default:
                        displayIcon = null;
                        break;
                    }

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF9C9EAB),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(room.nickname),
                      subtitle: Text(room.lastMessage),
                      trailing: displayIcon, // ✅ displayIcon 변수 사용
                      onTap: () async {
                        debugPrint("[MessageListScreen] ListTile tapped: roomId=${room.roomId}, postId=${room.postId}");
                        if (widget.onChatPressed == null) {
                          debugPrint("[MessageListScreen] onChatPressed is null. Aborting.");
                          return;
                        }

                        Map<String, dynamic> postDataForCallback = {};
                        if (room.postId != null && room.postId!.trim().isNotEmpty) {
                          debugPrint("[MessageListScreen] Fetching post data for postId: ${room.postId}");
                          // 로딩 다이얼로그 표시 (간단한 버전)
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(child: CircularProgressIndicator());
                            },
                          );
                          try {
                            postDataForCallback = await _postService.fetchPostById(room.postId!);
                            if (mounted) Navigator.pop(context); // 로딩 다이얼로그 닫기
                            debugPrint("[MessageListScreen] Successfully fetched post data: $postDataForCallback");
                          } catch (e, s) {
                            if (mounted) Navigator.pop(context);
                            debugPrint("[MessageListScreen] Failed to fetch post data for postId: ${room.postId}. Error: $e, Stacktrace: $s");
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('게시글 정보를 불러오는 데 실패했습니다: $e')),
                              );
                            }
                          }
                        } else {
                          debugPrint("[MessageListScreen] postId is null or empty. Not fetching post data. postId: '${room.postId}'");
                        }

                        debugPrint("[MessageListScreen] Calling onChatPressed with roomId=${room.roomId}, postData=${postDataForCallback.isNotEmpty ? '{...data...}' : '{}'}");
                        widget.onChatPressed!(
                          roomId: room.roomId,
                          profileImage: room.profileImage,
                          nickname: room.nickname,
                          opponentUsername: room.opponentUsername,
                          postData: postDataForCallback,
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}