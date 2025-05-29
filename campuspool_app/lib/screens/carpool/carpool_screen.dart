import 'package:flutter/material.dart';

class CarpoolScreen extends StatelessWidget {
  const CarpoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 카풀 아이콘
              SizedBox(
                height: 200,
                child: Center(
                  child: Icon(
                    Icons.directions_car_rounded,
                    size: 80,
                    color: Colors.black.withAlpha((0.8*255).round())
                  ),
                ),
              ),
              // 입력 필드들
              _buildInputField("출발지", "출발 위치를 입력하세요"),
              const SizedBox(height: 20),
              _buildInputField("도착지", "도착 위치를 입력하세요"),
              const Spacer(),
              // 하단 버튼
              _buildBottomButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withAlpha((0.4*255).round()),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.black.withAlpha((0.7*255).round()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      height: 67,
      decoration: BoxDecoration(
        color: const Color(0xFFEC5F5F),
        borderRadius: BorderRadius.circular(33.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC5F5F).withAlpha((0.25*255).round()),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "카풀 시작하기",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
} 