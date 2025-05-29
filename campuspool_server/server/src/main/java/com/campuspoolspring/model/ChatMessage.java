package com.campuspoolspring.model;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ChatMessage {
    private String roomId;
    private String sender;
    private String receiver;
    private String message;
    private LocalDateTime timestamp = LocalDateTime.now();
}
