import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../models/chat_room.dart';
import '../../models/message.dart';

class ChatService {
  final String baseUrl = 'http://10.0.2.2:8080'; // ✅ 로컬 서버 주소 (Android 에뮬레이터용)
  StompClient? stompClient;

  Future<List<ChatRoom>> fetchChatRooms(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/rooms/$username'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => ChatRoom.fromJson(json)).toList();
      } else {
        throw Exception('채팅방 목록 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('HTTP 요청 오류: $e');
      throw Exception('채팅방 목록 불러오기 중 오류 발생');
    }
  }

  Future<List<MessageModel>> fetchMessages(String roomId, String currentUser) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/room/$roomId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => MessageModel.fromJson(e, currentUser)).toList();
      } else {
        throw Exception('메시지 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('메시지 로딩 오류: $e');
      throw Exception('메시지 불러오기 중 오류 발생');
    }
  }

  void connectToRoom({
    required String roomId,
    required String currentUser,
    required Function(dynamic) onMessageReceived,
  }) {
    try {
      stompClient = StompClient(
        config: StompConfig(
          url: 'ws://10.0.2.2:8080/ws-chat', // ✅ WebSocket 전용 URL로 변경
          onConnect: (StompFrame frame) {
            print('✅ WebSocket 연결 성공');
            stompClient?.subscribe(
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
          onWebSocketError: (dynamic error) =>
              print('❌ WebSocket 에러 발생: $error'),
          onDisconnect: (frame) => print('❗ WebSocket 연결 해제'),
          onStompError: (frame) =>
              print('❌ STOMP 프로토콜 에러: ${frame.body}'),
          heartbeatOutgoing: const Duration(seconds: 10),
          heartbeatIncoming: const Duration(seconds: 10),
        ),
      );

      stompClient?.activate();
    } catch (e) {
      print('WebSocket 연결 예외 발생: $e');
    }
  }

  void disconnect() {
    stompClient?.deactivate();
    print('🔌 WebSocket 연결 해제 완료');
  }

  void sendMessage({
    required String sender,
    required String receiver,
    required String message,
  }) {
    try {
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
      print('📤 메시지 전송 완료');
    } catch (e) {
      print('📛 메시지 전송 오류: $e');
    }
  }
}
