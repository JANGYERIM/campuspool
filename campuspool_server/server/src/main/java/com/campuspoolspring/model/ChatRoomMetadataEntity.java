// com/campuspoolspring/model/ChatRoomMetadataEntity.java
package com.campuspoolspring.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "chat_room_metadata")
public class ChatRoomMetadataEntity {

    @Id
    @Column(name = "room_id", nullable = false, unique = true)
    private String roomId; // 채팅방 ID (예: user1_user2)

    @Column(name = "first_post_id")
    private String firstPostId; // 이 채팅방과 처음 연결된 게시물 ID

    // 기본 생성자 (JPA 필요)
    public ChatRoomMetadataEntity() {
    }

    public ChatRoomMetadataEntity(String roomId, String firstPostId) {
        this.roomId = roomId;
        this.firstPostId = firstPostId;
    }

    // Getters and Setters
    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public String getFirstPostId() {
        return firstPostId;
    }

    public void setFirstPostId(String firstPostId) {
        this.firstPostId = firstPostId;
    }
}