package com.campuspoolspring.repository;

import java.util.List;
import com.campuspoolspring.model.Post;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query; // @Query 어노테이션 임포트
import org.springframework.data.repository.query.Param; // @Param 어노테이션 임포트

public interface PostRepository extends JpaRepository<Post, Long> {
    List<Post> findByDriver(boolean driver);

    @Query("SELECT p FROM Post p JOIN p.user u WHERE " +
            "LOWER(p.departure) LIKE LOWER(concat('%', :keyword, '%')) OR " +
            "LOWER(p.destination) LIKE LOWER(concat('%', :keyword, '%')) OR " +
            "LOWER(u.nickname) LIKE LOWER(concat('%', :keyword, '%'))")
    List<Post> findByKeywordInDepartureOrDestinationOrUserNickname(@Param("keyword") String keyword);

}

