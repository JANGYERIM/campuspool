// lib/models/user.dart

class User {
  final int id; // ✅ 서버에서 오는 숫자 ID (DB의 기본 키)
  final String userId; // ✅ 서버에서 오는 UUID 형태의 문자열 ID
  final String email;
  final String name;
  final String? nickname; // Postman 응답에 nickname도 있었음
  final String? profileImage;
  final String? phoneNumber;

  User({
    required this.id,
    required this.userId,
    required this.email,
    required this.name,
    this.nickname,
    this.profileImage,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int, // ✅ int로 받고 as int
      userId: json['userId'] as String, // ✅ String으로 받고 as String
      email: json['email'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String?, // nickname도 추가 (null 가능성)
      profileImage: json['profileImage'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'email': email,
      'name': name,
      'nickname': nickname,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
    };
  }
}