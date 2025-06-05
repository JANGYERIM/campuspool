import 'package:flutter/material.dart';
import '../../services/api/post_service.dart';
import '../../models/post_summary.dart';
import '../post/post_detail_screen.dart';
import 'package:intl/intl.dart';

class PostListScreen extends StatefulWidget {
  final void Function({
    required String roomId,
    required String profileImage,
    required String nickname,
    required String opponentUsername,
    required Map<String, dynamic> postData,
  })? onChatPressed;

  const PostListScreen({super.key, this.onChatPressed});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List<PostSummary> _posts = []; // 직접 데이터 리스트를 관리
  late Future<List<PostSummary>> _postsFuture;
  final PostService _postService = PostService();
  final TextEditingController _searchController = TextEditingController();
  bool _isDriverTab = false;
  String _currentKeyword = '';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts({String? keywordFromSearch}) { // 파라미터 이름을 명확히 변경
    setState(() {
      if (keywordFromSearch != null && keywordFromSearch.trim().isNotEmpty) {
        // 검색어가 제공되면, 해당 키워드로 검색 API를 호출하는 Future를 할당
        _currentKeyword = keywordFromSearch.trim();
        _postsFuture = _postService.searchPostsByKeyword(keyword: _currentKeyword);
      } else {
        // 검색어가 없거나 비어있으면, 역할(탭) 기반으로 게시물을 가져오는 Future를 할당
        _currentKeyword = ''; // 검색어 상태 초기화
        _searchController.clear(); // 탭 변경 시 검색창을 비울지 여부는 UX에 따라 결정
        _postsFuture = _postService.fetchPosts(isDriverTab: _isDriverTab, keyword: ''); // fetchPosts는 빈 키워드로
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final timeFormat = DateFormat('HH:mm'); // 이 줄은 build() 메서드 안에 선언하거나 클래스 멤버로 선언해줘야 함


    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
          // 🔍 검색창
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '지역, 키워드를 검색하세요.',
                      hintStyle: theme.bodyLarge,
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (value) {
                      _loadPosts(keywordFromSearch: value); // 검색어로 게시물 로드
                    },
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: (){_loadPosts(keywordFromSearch: _searchController.text);},
                  child: Container(
                    width: 73,
                    height: 30,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFEB5F5F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x3FEC5F5F),
                          blurRadius: 14,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text('검색', style: theme.bodyLarge?.copyWith(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🧭 탭 전환
          Container(
            height: 56,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    if(!_isDriverTab) return; // 이미 탑승자 탭이면 아무 동작도 하지 않음
                    setState(() {
                      _isDriverTab = false;
                      _searchController.clear(); // 탭 전환 시 검색창 비우기
                    });
                    _loadPosts(); //_is DriverTab이 false 일 때 
                  },
                  child: Text(
                    '탑승자',
                    style: theme.bodyLarge?.copyWith(
                      color: _isDriverTab ? Colors.black : const Color(0xFFEB5F5F),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDriverTab = true;
                      _searchController.clear(); // 탭 전환 시 검색창 비우기
                    });
                    _loadPosts(); // _isDriverTab이 true 일 때
                  },
                  child: Text(
                    '운전자',
                    style: theme.bodyLarge?.copyWith(
                      color: _isDriverTab ? const Color(0xFFEB5F5F) : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 2, thickness: 2, color: Colors.white),

          // 📋 게시물 목록
          Expanded(
            child: FutureBuilder<List<PostSummary>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('에러 발생: ${snapshot.error}', style: theme.bodyLarge));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car_outlined, size: 50, color: Color(0xFFEB5F5F)),
                        SizedBox(height: 16),
                        Text(_currentKeyword.isEmpty ? '등록된 게시물이 없습니다.' : '검색 결과가 없습니다.',
                          style: theme.bodyLarge),
                      ],
                    ),
                  );
                }

                final posts = snapshot.data!;

                return RefreshIndicator(
                  onRefresh: () async {
                    // 현재 상태에 따라 _loadPosts 호출
                    if (_currentKeyword.isNotEmpty) {
                      _loadPosts(keywordFromSearch: _currentKeyword); // 현재 키워드로 새로고침
                    } else {
                      _loadPosts(); // 역할 기반으로 새로고침
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 15),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                postId: post.id,
                                onChatPressed: widget.onChatPressed, // ✅ 콜백 그대로 전달
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 0),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      _buildRouteIcon(),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${timeFormat.format(post.departureTime)}      ${post.departure}', style: theme.bodyMedium),
                                          const SizedBox(height: 15),
                                          Text('${timeFormat.format(post.arrivalTime)}      ${post.destination}', style: theme.bodyMedium),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text('${post.fare} 원', style: theme.bodyMedium?.copyWith(color: const Color(0xFFEB5F5F), fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 21,
                                    backgroundColor: Color(0xFF9C9EAB),
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(post.nickname, style: theme.bodyMedium?.copyWith(color: Colors.black)),
                                      Text(post.date.toString().substring(0, 10), style: theme.bodySmall),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteIcon() {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          const SizedBox(height: 9),
          SizedBox(
            width: 9.89,
            height: 54.89,
            child: Stack(
              children: [
                Positioned(
                  left: 4.5,
                  top: 9,
                  child: SizedBox(
                    width: 1.5,
                    height: 37,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFEB5F5F),
                      ),
                        ),
                      ),
                    ),
                const Positioned(
                  left: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 4.95,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 4.5,
                      backgroundColor: Color(0xFFEB5F5F),
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  top: 45,
                  child: CircleAvatar(
                    radius: 4.95,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 4.5,
                      backgroundColor: Color(0xFFEB5F5F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
