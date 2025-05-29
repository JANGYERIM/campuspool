import 'package:campuspool_app/utils/user_util.dart';
import 'package:flutter/material.dart';
import 'package:campuspool_app/screens/message/chat_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Map<String, dynamic>? postData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPostDetails();
  }

  Future<void> fetchPostDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/posts/${widget.postId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        setState(() {
          postData = jsonDecode(decodedBody);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }

  String formatTime(String timeStr) {
    final time = DateFormat('HH:mm:ss').parse(timeStr);
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (postData == null) {
      return const Scaffold(
        body: Center(child: Text('게시물을 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            
            Align(
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      Text(
                        formatDate(postData!['date']),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              const _LargeRedDot(),
                              Container(
                                width: 3,
                                height: 60,
                                color: const Color(0xFFEB5F5F),
                              ),
                              const _LargeRedDot(),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${formatTime(postData!['departureTime'])}  ${postData!['departure']}',
                                  style: _infoStyle,
                                ),
                                const SizedBox(height: 60),
                                Text(
                                  '${formatTime(postData!['arrivalTime'])}  ${postData!['destination']}',
                                  style: _infoStyle,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 30),
                              Text(
                                '${postData!['fare']}원',
                                style: const TextStyle(
                                  color: Color(0xFFEB5F5F),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(thickness: 1, color: Color(0xFF8C8C8C)),
                      const SizedBox(height: 16),
                      Text(
                        postData!['detail'] ?? '',
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(thickness: 1, color: Color(0xFF8C8C8C)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage('https://placehold.co/62x62'),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            postData!['nickname'] ?? '익명',
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  print('뒤로가기 버튼이 눌렸습니다.');
                  Navigator.pop(context);
                }
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async{
                          final currentUser = await getLoginUserId();
                          print ('postData: $postData');
                          if (currentUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('로그인이 필요합니다.')),
                            );
                            return;
                          }

                          // 게시물 작성자 ID(상대방)
                          final opponentUserId = postData!['userId'];
                          print('opponentUserId: $opponentUserId');
                          if (opponentUserId ==null){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('게시물 작성자 정보를 찾을 수 없습니다.')),
                            );
                            return;
                          }

                          //roomID
                          List<String>users = [currentUser, opponentUserId]..sort();
                          final roomId = '${users[0]}_${users[1]}';
                          print('생성된 roomId: $roomId');

                          // 닉네임 프로필 이미지
                          final opponentNickname = postData!['nickname'] ?? '익명';
                          final opponentProfileImage = postData!['profileImage'] ?? 'https://placehold.co/62x62';

                          // 채팅 화면 이동
                          Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                roomId: roomId,
                                nickname: opponentNickname,
                                profileImage: opponentProfileImage,
                                opponentUsername: opponentUserId,
                                postData: postData!,

                              ),
                            ),
                          );

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEB5F5F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '대화하기',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEB5F5F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '예약 요청',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LargeRedDot extends StatelessWidget {
  const _LargeRedDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFEB5F5F), width: 3),
      ),
    );
  }
}

const TextStyle _infoStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w700,
);
