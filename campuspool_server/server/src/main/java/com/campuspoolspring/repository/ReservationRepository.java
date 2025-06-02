package com.campuspoolspring.repository; // 본인의 패키지 경로에 맞게 수정

import com.campuspoolspring.model.Post;
import com.campuspoolspring.model.Reservation;
import com.campuspoolspring.model.ReservationStatus;
import com.campuspoolspring.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    // 특정 게시물과 특정 요청자에 대한 예약 조회 (중복 예약 방지 또는 기존 예약 확인용)
    Optional<Reservation> findByPostAndRequester(Post post, User requester);

    // 특정 게시물에 대한 모든 예약 목록 조회 (운전자가 자신의 게시물에 대한 요청들 볼 때)
    List<Reservation> findByPost(Post post);

    // 특정 게시물에 대한 특정 상태의 예약 목록 조회
    List<Reservation> findByPostAndStatus(Post post, ReservationStatus status);

    // 특정 요청자가 한 모든 예약 목록 조회
    List<Reservation> findByRequester(User requester);

    // 특정 게시물 작성자의 게시물들에 대한 모든 예약 목록 조회
    List<Reservation> findByAuthor(User author);

    // 특정 게시물 ID와 사용자 ID (요청자 또는 작성자)로 예약 상태를 조회하기 위한 좀 더 복잡한 쿼리가 필요할 수 있음
    // 예: postId와 requesterId 또는 postId와 authorId로 조회하는 메소드
    // 이 부분은 ChatDetailScreen에서 예약 상태를 가져올 때 필요
    Optional<Reservation> findByPostAndRequesterOrPostAndAuthor(Post post1, User requester, Post post2, User author);
    // 위 메소드는 조금 복잡하니, 서비스 계층에서 로직으로 처리하거나, 아래처럼 분리하는 것이 나을 수 있음
    // 혹은 postId로 조회 후, 서비스에서 requester/author 비교

    // 특정 게시물(Post)에 대해 특정 사용자(User)가 요청자(requester)이거나 작성자(author)인 예약을 찾는 메소드
    // 이 메소드는 ChatDetailScreen에서 해당 게시물의 예약 상태를 가져올 때 유용.
    // 하나의 게시물에 대해 사용자는 요청자이거나 작성자 중 하나일 것.
    // (만약 한 사용자가 자신의 게시물에 예약 요청을 하는 시나리오가 없다면 더 간단해짐)
    @Query("SELECT r FROM Reservation r WHERE r.post = :post AND (r.requester = :user OR r.author = :user)")
    Optional<Reservation> findByPostAndUser(@Param("post") Post post, @Param("user") User user);

    // 특정 게시물 ID에 해당하는 예약들을 조회 (메시지 목록 화면에서 사용될 수 있음)
    List<Reservation> findByPostId(Long postId);
}