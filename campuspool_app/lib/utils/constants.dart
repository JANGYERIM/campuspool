class ApiConstants {
  // API 기본 URL (개발 환경)
  static const String baseUrl = 'http://10.0.2.2:8080'; // Android Emulator용
  // static const String baseUrl = 'http://localhost:3000'; // iOS Simulator용
  
  // 인증 관련 엔드포인트
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String profile = '/api/auth/profile';

  // 정보 업데이트
  static const String profileUpdate = '/api/auth/update';
  
  // 카풀 관련 엔드포인트
  static const String carpools = '/api/carpools';
  static const String searchCarpools = '/api/carpools/search';
  
  // 예약 관련 엔드포인트
  static const String reservations = '/api/reservations';
  
  // 채팅 관련 엔드포인트
  static const String chatRooms = '/api/chat/rooms';
  static const String messages = '/api/chat/messages';
  
  // 웹소켓
  static const String wsUrl = 'ws://10.0.2.2:3000/chat';
} 