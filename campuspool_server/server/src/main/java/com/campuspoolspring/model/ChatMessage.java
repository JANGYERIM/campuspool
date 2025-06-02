// com/campuspoolspring/model/ChatMessage.java
package com.campuspoolspring.model;

import java.time.LocalDateTime; // 또는 사용하고 계신 timestamp 타입 (예: String)

public class ChatMessage {
    private String sender;
    private String receiver;
    private String message;
    private LocalDateTime timestamp = LocalDateTime.now();// 사용하고 계신 실제 타입으로 확인해주세요.
    private String postId;

    private String roomId;           // ✅ roomId 필드 추가

    // 기본 생성자
    public ChatMessage() {
    }

    // 모든 필드를 초기화하는 생성자 (선택 사항)
    public ChatMessage(String sender, String receiver, String message, LocalDateTime timestamp, String postId, String roomId) {
        this.sender = sender;
        this.receiver = receiver;
        this.message = message;
        this.timestamp = timestamp;
        this.postId = postId;
        this.roomId = roomId;      // ✅ 생성자에 roomId 초기화 추가
    }

    // Getters and Setters
    public String getSender() { return sender; }
    public void setSender(String sender) { this.sender = sender; }

    public String getReceiver() { return receiver; }
    public void setReceiver(String receiver) { this.receiver = receiver; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }

    public String getPostId() { return postId; }
    public void setPostId(String postId) { this.postId = postId; }

    // ✅ roomId 필드에 대한 Getter와 Setter 추가
    public String getRoomId() { return roomId; }
    public void setRoomId(String roomId) { this.roomId = roomId; }
}