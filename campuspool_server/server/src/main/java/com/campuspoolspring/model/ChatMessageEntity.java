package com.campuspoolspring.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "chat_messages")
@Data
public class ChatMessageEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String roomId; // 🔥 추가!
    private String sender;
    private String receiver;
    private String message;
    private LocalDateTime timestamp;
}
