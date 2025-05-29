import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFFFEFAFA),
      child: SizedBox(
        height: 88,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem("예약", "https://placehold.co/28x28"),
            _buildNavItem("검색", "https://placehold.co/26x27"),
            _buildNavItem("등록하기", "https://placehold.co/28x29"),
            _buildNavItem("메시지", "https://placehold.co/28x29"),
            _buildNavItem("프로필", "https://placehold.co/29x29"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, String imageUrl) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            width: 28,
            height: 28,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 24, color: Colors.grey);
              },
            ),
          ),
          const SizedBox(height: 5),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
