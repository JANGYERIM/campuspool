package com.campuspoolspring.service;

import com.campuspoolspring.model.User;
import com.campuspoolspring.repository.*;
import com.campuspoolspring.model.ChatRoomSummary;
import com.campuspoolspring.model.ChatMessage;
import com.campuspoolspring.model.ChatMessageEntity;
import com.campuspoolspring.model.ChatRoomMetadataEntity;
import com.campuspoolspring.model.Reservation;
import com.campuspoolspring.model.Post;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
@Transactional // 클래스 레벨 트랜잭션 적용
public class ChatService {
    private final ChatMessageRepository chatMessageRepository;
    private final ChatRoomMetadataRepository chatRoomMetadataRepository;
    private final UserRepository userRepository;
    private final PostRepository postRepository;
    private final ReservationRepository reservationRepository;

    public ChatService(ChatMessageRepository chatMessageRepository,
                       ChatRoomMetadataRepository chatRoomMetadataRepository,
                       UserRepository userRepository,
                       PostRepository postRepository,
                       ReservationRepository reservationRepository) {
        this.chatMessageRepository = chatMessageRepository;
        this.chatRoomMetadataRepository = chatRoomMetadataRepository;
        this.userRepository = userRepository;
        this.postRepository = postRepository;
        this.reservationRepository = reservationRepository;
    }

    public String generateRoomId(String user1, String user2) {
        return Stream.of(user1, user2)
                .sorted()
                .collect(Collectors.joining("_"));
    }

    public ChatMessage save(ChatMessage messageDto) {
        ChatMessageEntity entity = new ChatMessageEntity();
        String roomId = generateRoomId(messageDto.getSender(), messageDto.getReceiver());
        entity.setRoomId(roomId);
        entity.setSender(messageDto.getSender());
        entity.setReceiver(messageDto.getReceiver());
        entity.setMessage(messageDto.getMessage());
        entity.setTimestamp(messageDto.getTimestamp());
        chatMessageRepository.save(entity);
        if (messageDto.getPostId() != null && !messageDto.getPostId().isEmpty()) {
            saveChatRoomMetadataIfNotExist(roomId, messageDto.getPostId());
        }
        return messageDto;
    }

    private void saveChatRoomMetadataIfNotExist(String roomId, String postId) {
        Optional<ChatRoomMetadataEntity> metadataOptional = chatRoomMetadataRepository.findByRoomId(roomId);
        if (metadataOptional.isEmpty()) {
            ChatRoomMetadataEntity newMetadata = new ChatRoomMetadataEntity(roomId, postId);
            chatRoomMetadataRepository.save(newMetadata);
            System.out.println("Saved new ChatRoomMetadata for roomId: " + roomId + " with firstPostId: " + postId);
        } else {
            System.out.println("ChatRoomMetadata already exists for roomId: " + roomId +
                    ". Current firstPostId: " + metadataOptional.get().getFirstPostId() +
                    ". New postId '" + postId + "' will not overwrite it as firstPostId.");
        }
    }

    @Transactional(readOnly = true)
    public List<ChatMessage> getMessages(String roomId) {
        return chatMessageRepository
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

    @Transactional(readOnly = true)
    public List<ChatRoomSummary> getChatRoomsForUser(String currentUserIdStr) {
        List<String> roomIds = chatMessageRepository.findDistinctRoomIdsByUsername(currentUserIdStr);

        if (roomIds.isEmpty()) {
            return List.of();
        }

        List<ChatMessageEntity> lastMessages = chatMessageRepository.findLastMessagesForRooms(roomIds);
        User currentUser = userRepository.findByUserId(currentUserIdStr)
                .orElseThrow(() -> new IllegalArgumentException("현재 사용자 정보를 찾을 수 없습니다: " + currentUserIdStr));

        return lastMessages.stream().map(msg -> {
            String opponentUsername = msg.getSender().equals(currentUserIdStr) ? msg.getReceiver() : msg.getSender();

            String opponentDisplayNickname = userRepository.findByUserId(opponentUsername)
                    .map(User::getNickname)
                    .filter(nickname -> nickname != null && !nickname.trim().isEmpty())
                    .orElse("익명");

            String opponentProfileImageUrl = "https://placehold.co/52x52";

            String firstPostIdStr = chatRoomMetadataRepository.findByRoomId(msg.getRoomId())
                    .map(ChatRoomMetadataEntity::getFirstPostId)
                    .orElse(null);

            System.out.println("Processing roomId: " + msg.getRoomId() + ", firstPostIdStr from metadata: " + firstPostIdStr);

            String reservationStatusStr = "NONE";
            String currentUserRoleInRes = "NONE";

            if (firstPostIdStr != null && !firstPostIdStr.isEmpty()) {
                try {
                    Long postId = Long.parseLong(firstPostIdStr);
                    System.out.println("Parsed postId: " + postId);
                    Optional<Post> postOpt = postRepository.findById(postId);

                    if (postOpt.isPresent()) {
                        Post post = postOpt.get();
                        System.out.println("Found Post: " + post.getId());
                        Optional<Reservation> reservationOpt = reservationRepository.findByPostAndUser(post, currentUser);

                        if (reservationOpt.isPresent()) {
                            Reservation reservation = reservationOpt.get();
                            System.out.println("Found Reservation: " + reservation.getId() + ", Status: " + reservation.getStatus());
                            if (reservation.getStatus() != null) {
                                reservationStatusStr = reservation.getStatus().name();
                            } else {
                                System.err.println("Reservation status is NULL for reservationId: " + reservation.getId());
                            }
                            if (reservation.getRequester().equals(currentUser)) {
                                currentUserRoleInRes = "REQUESTER";
                            } else if (reservation.getAuthor().equals(currentUser)) {
                                currentUserRoleInRes = "AUTHOR";
                            }
                            System.out.println("currentUserRoleInRes set to: " + currentUserRoleInRes);
                        } else{
                            System.out.println("No reservation found for post " + post.getId() + " and user " + currentUser.getUserId());
                        }
                    } else {
                        System.err.println("Post not found for postId: " + postId + " in ChatService for chat room summary.");
                    }
                } catch (NumberFormatException e) {
                    System.err.println("Invalid postId format in ChatRoomMetadata: " + firstPostIdStr + " for chat room summary.");
                } catch (Exception e) {
                    System.err.println("Error fetching reservation info for postId " + firstPostIdStr + ": " + e.getMessage());
                } // ✅ try-catch 블록의 닫는 괄호
            } else { // ✅ if (firstPostIdStr != null && !firstPostIdStr.isEmpty()) 에 대한 else 블록
                System.out.println("firstPostIdStr is null or empty for roomId: " + msg.getRoomId());
            } // ✅ if-else 블록의 닫는 괄호. 이 괄호가 이전 코드에서 누락되었거나 위치가 잘못됨.

            // ✅ 이 로그는 if-else 블록 바깥에 있어야 함 (항상 실행되도록)
            System.out.println("Final reservationStatusStr: " + reservationStatusStr + ", currentUserRoleInRes: " + currentUserRoleInRes + " for roomId: " + msg.getRoomId());

            return new ChatRoomSummary(
                    msg.getRoomId(),
                    opponentUsername,
                    msg.getMessage(),
                    opponentProfileImageUrl,
                    opponentDisplayNickname,
                    firstPostIdStr,
                    reservationStatusStr,
                    currentUserRoleInRes
            );
        }).collect(Collectors.toList());
    }
}