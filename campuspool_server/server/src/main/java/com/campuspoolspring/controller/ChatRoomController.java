package com.campuspoolspring.controller;

import com.campuspoolspring.model.ChatRoomSummary;
import com.campuspoolspring.service.ChatService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
public class ChatRoomController {

    private final ChatService chatService;

    public ChatRoomController(ChatService chatService) {
        this.chatService = chatService;
    }

    // 💬 채팅방 목록 조회 (로그인 유저 기준)
    @GetMapping("/rooms/{username}")
    public List<ChatRoomSummary> getChatRooms(@PathVariable String username) {
        return chatService.getChatRoomsForUser(username);
    }
}
