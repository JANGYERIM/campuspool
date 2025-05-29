package com.campuspoolspring.service;

import com.campuspoolspring.model.ChatMessage;
import com.campuspoolspring.model.ChatMessageEntity;
import com.campuspoolspring.model.ChatRoomSummary;
import com.campuspoolspring.repository.ChatMessageRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
public class ChatService {
    private final ChatMessageRepository repository;

    public ChatService(ChatMessageRepository repository) {
        this.repository = repository;
    }

    public String generateRoomId(String user1, String user2) {
        return Stream.of(user1, user2)
                .sorted()
                .collect(Collectors.joining("_"));
    }

    public ChatMessage save(ChatMessage message) {
        ChatMessageEntity entity = new ChatMessageEntity();

        entity.setSender(message.getSender());
        entity.setReceiver(message.getReceiver());
        entity.setMessage(message.getMessage());
        entity.setTimestamp(message.getTimestamp());
        entity.setRoomId(generateRoomId(message.getSender(), message.getReceiver()));

        repository.save(entity);
        return message;
    }

    public List<ChatMessage> getMessages(String roomId) {
        return repository
                .findByRoomIdOrderByTimestampAsc(roomId)
                .stream()
                .map(entity -> {
                    ChatMessage dto = new ChatMessage();
                    dto.setSender(entity.getSender());
                    dto.setReceiver(entity.getReceiver());
                    dto.setMessage(entity.getMessage());
                    dto.setTimestamp(entity.getTimestamp());
                    return dto;
                })
                .collect(Collectors.toList());
    }

    public List<ChatRoomSummary> getChatRoomsForUser(String username) {
        List<String> roomIds = repository.findDistinctRoomIdsByUsername(username);
        List<ChatMessageEntity> lastMessages = repository.findLastMessagesForRooms(roomIds);

        return lastMessages.stream().map(msg -> {
            String opponent = msg.getSender().equals(username) ? msg.getReceiver() : msg.getSender();
            return new ChatRoomSummary(
                    msg.getRoomId(),
                    opponent,
                    msg.getMessage(),
                    "https://placehold.co/52x52"
            );
        }).collect(Collectors.toList());
    }

}
