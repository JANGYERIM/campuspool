// com/campuspoolspring/repository/ChatRoomMetadataRepository.java
package com.campuspoolspring.repository;

import com.campuspoolspring.model.ChatRoomMetadataEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ChatRoomMetadataRepository extends JpaRepository<ChatRoomMetadataEntity, String> {
    // roomId로 ChatRoomMetadataEntity를 찾는 메소드
    Optional<ChatRoomMetadataEntity> findByRoomId(String roomId);
}