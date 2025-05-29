package com.campuspoolspring.repository;

import com.campuspoolspring.model.ChatMessageEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessageEntity, Long> {

    // ✅ 특정 roomId에 대한 모든 메시지 조회 (시간순 정렬)
    List<ChatMessageEntity> findByRoomIdOrderByTimestampAsc(String roomId);

    // ✅ 사용자가 참여한 모든 roomId 목록 조회
    @Query("SELECT DISTINCT c.roomId FROM ChatMessageEntity c WHERE c.sender = :username OR c.receiver = :username")
    List<String> findDistinctRoomIdsByUsername(@Param("username") String username);

    // ✅ 각 roomId에 대해 마지막 메시지 1개씩 조회
    @Query("SELECT c FROM ChatMessageEntity c WHERE c.roomId IN :roomIds AND c.timestamp IN " +
            "(SELECT MAX(c2.timestamp) FROM ChatMessageEntity c2 WHERE c2.roomId = c.roomId GROUP BY c2.roomId)")
    List<ChatMessageEntity> findLastMessagesForRooms(@Param("roomIds") List<String> roomIds);
}
