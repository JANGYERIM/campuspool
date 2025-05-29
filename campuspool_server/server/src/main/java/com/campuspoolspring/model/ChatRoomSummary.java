package com.campuspoolspring.model;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ChatRoomSummary {
    private String roomId;
    private String opponentUsername;
    private String lastMessage;
    private String profileImage;
}
