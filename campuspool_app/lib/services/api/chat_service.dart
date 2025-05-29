import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:web_socket_channel/io.dart';

import '../../models/chat_room.dart';
import '../../models/message.dart';

class ChatService {
  final String baseUrl = 'http://10.0.2.2:8080'; // Android emulator 기준

  Future<List<ChatRoom>> fetchChatRooms(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/chat/rooms/$username'));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => ChatRoom.fromJson(json)).toList();
      } else {
        // 상태 코드와 응답 본문을 로그로 출력
        print('Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('채팅방 목록 불러오기 실패');
      }
    } catch (e) {
      // 네트워크 오류 등 예외 처리
      print('HTTP 요청 중 오류 발생: $e');
      throw Exception('채팅방 목록을 불러오는 중 오류가 발생했습니다.');
    }
  }

  final String currentUser = 'userA';
  StompClient? stompClient;

  /// 과거 메시지 불러오기
  Future<List<MessageModel>> fetchMessages(String roomId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/chat/room/$roomId'));
    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      return data.map((e) => MessageModel.fromJson(e, currentUser)).toList();
    } else {
      throw Exception('메시지 불러오기 실패: ${res.statusCode}');
    }
  }

  /// WebSocket 연결 및 구독
  void connectToRoom({
    required String roomId,
    required String currentUser,
    required Function(Map<String, dynamic>) onMessageReceived,
  }) {
    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: '$baseUrl/ws',
        onConnect: (StompFrame frame) {
          print('✅ WebSocket 연결됨');

          stompClient!.subscribe(
            destination: '/topic/chat.$roomId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                final data = json.decode(frame.body!);
                onMessageReceived(data);
              }
            },
          );
        },
        beforeConnect: () async {
          print('🔄 WebSocket 연결 중...');
          await Future.delayed(const Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) => print('❌ WebSocket 오류: $error'),
        onDisconnect: (frame) => print('🔌 연결 해제됨'),
        onStompError: (frame) => print('🚨 STOMP 오류: ${frame.body}'),
      ),
    );

    stompClient!.activate();
  }

  /// WebSocket 메시지 전송
  void sendMessage({
    required String sender,
    required String receiver,
    required String message,
  }) {
    final payload = {
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };

    stompClient?.send(
      destination: '/app/chat.send',
      body: json.encode(payload),
    );
  }

  /// WebSocket 연결 종료
  void disconnect() {
    stompClient?.deactivate();
    print('🔌 WebSocket 연결 종료됨');
  }
}
