// com/campuspoolspring/model/ChatRoomSummary.java
package com.campuspoolspring.model;

public class ChatRoomSummary {
    private String roomId;
    private String opponentUsername;
    private String lastMessage;
    private String profileImage;
    private String nickname;
    private String postId; // 이 필드를 firstPostId로 사용
    private String reservationStatus;
    private String currentUserRoleInReservation;

    // 생성자에서 postId (firstPostId)를 받도록 함
    public ChatRoomSummary(String roomId, String opponentUsername, String lastMessage, String profileImage, String nickname, String postId, String reservationStatus, String currentUserRoleInReservation) {
        this.roomId = roomId;
        this.opponentUsername = opponentUsername;
        this.lastMessage = lastMessage;
        this.profileImage = profileImage;
        this.nickname = nickname;
        this.postId = postId; // firstPostId 값을 여기에 할당
        this.reservationStatus = reservationStatus;
        this.currentUserRoleInReservation = currentUserRoleInReservation;
    }

    // Getters
    public String getRoomId() { return roomId; }
    public String getOpponentUsername() { return opponentUsername; }
    public String getLastMessage() { return lastMessage; }
    public String getProfileImage() { return profileImage; }
    public String getNickname() { return nickname; }
    public String getPostId() { return postId; } // 이것이 firstPostId를 의미
    public String getReservationStatus() { return reservationStatus; }
    public String getCurrentUserRoleInReservation() { return currentUserRoleInReservation; }
}