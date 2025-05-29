import 'package:flutter/material.dart';
import '../../services/api/post_service.dart';
import '../../models/post_summary.dart';
import '../post/post_detail_screen.dart';

class PostListScreen extends StatefulWidget {
  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late Future<List<PostSummary>> _postsFuture;
  final PostService _postService = PostService();
  final TextEditingController _searchController = TextEditingController();
  bool _isDriverTab = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      _postsFuture = _postService.fetchPosts(isDriverTab: _isDriverTab);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
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
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _loadPosts();
                  },
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
          Container(
            height: 56,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDriverTab = false;
                    });
                    _loadPosts();
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
                    });
                    _loadPosts();
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
                        const Icon(Icons.directions_car_outlined, size: 50, color: Color(0xFFEB5F5F)),
                        const SizedBox(height: 16),
                        Text('등록된 게시물이 없습니다.', style: theme.bodyLarge),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadPosts();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 15),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(postId: post.id),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(20),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            shadows: const [
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
                                      SizedBox(
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
                                                    left: 4,
                                                    top: 6,
                                                    child: Container(
                                                      transform: Matrix4.identity()..rotateZ(1.57),
                                                      width: 46,
                                                      decoration: const ShapeDecoration(
                                                        shape: RoundedRectangleBorder(
                                                          side: BorderSide(width: 1.5, color: Color(0xFFEB5F5F)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 9.89,
                                                      height: 9.89,
                                                      decoration: const ShapeDecoration(
                                                        color: Colors.white,
                                                        shape: OvalBorder(
                                                          side: BorderSide(width: 2, color: Color(0xFFEB5F5F)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 0,
                                                    top: 45,
                                                    child: Container(
                                                      width: 9.89,
                                                      height: 9.89,
                                                      decoration: const ShapeDecoration(
                                                        color: Colors.white,
                                                        shape: OvalBorder(
                                                          side: BorderSide(width: 2, color: Color(0xFFEB5F5F)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${post.departureTime.toString().substring(11, 16)}      ${post.departure}',
                                            style: theme.bodyMedium,
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            '${post.arrivalTime.toString().substring(11, 16)}      ${post.destination}',
                                            style: theme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${post.fare} 원',
                                    style: theme.bodyMedium?.copyWith(
                                      color: const Color(0xFFEB5F5F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFF9C9EAB),
                                      shape: OvalBorder(),
                                    ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
