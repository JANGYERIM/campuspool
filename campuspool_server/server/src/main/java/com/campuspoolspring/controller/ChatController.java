package com.campuspoolspring.controller;

import com.campuspoolspring.model.ChatMessage;
import com.campuspoolspring.service.ChatService;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Controller
public class ChatController {

    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;

    public ChatController(ChatService chatService, SimpMessagingTemplate messagingTemplate) {
        this.chatService = chatService;
        this.messagingTemplate = messagingTemplate;
    }

    // ✅ 유저 쌍으로 고정된 roomId 생성
    private String generateRoomId(String sender, String receiver) {
        return Stream.of(sender, receiver).sorted().collect(Collectors.joining("_"));
    }

    // ✅ 실시간 메시지 전송 처리
    @MessageMapping("/chat.send")
    public void sendMessage(@Payload ChatMessage message) {
        message.setRoomId(generateRoomId(message.getSender(), message.getReceiver()));
        System.out.println("🔥 수신된 메시지: " + message);
        chatService.save(message); // DB 저장
        messagingTemplate.convertAndSend("/topic/chat." + message.getRoomId(), message); // 클라이언트에 전송
    }

    // ✅ 메시지 조회용 Rest API
    @RestController
    @RequestMapping("/api/chat")
    public static class ChatRestController {

        private final ChatService chatService;

        public ChatRestController(ChatService chatService) {
            this.chatService = chatService;
        }

        // 🔄 roomId로 채팅 내역 조회
        @GetMapping("/room/{roomId}")
        public List<ChatMessage> getMessages(@PathVariable String roomId) {
            return chatService.getMessages(roomId);
        }
    }
}
