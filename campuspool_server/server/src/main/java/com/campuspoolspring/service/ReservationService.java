package com.campuspoolspring.service;

import com.campuspoolspring.model.*; // Reservation, ReservationStatus, Post, User 등
import com.campuspoolspring.repository.PostRepository;
import com.campuspoolspring.repository.ReservationRepository;
import com.campuspoolspring.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional // 클래스 레벨 트랜잭션: 모든 public 메소드가 트랜잭션 내에서 실행
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final PostRepository postRepository;
    private final UserRepository userRepository; // User 엔티티 조회를 위해 추가

    /**
     * 새로운 예약을 요청합니다.
     * 요청자는 자신의 게시물에 예약할 수 없으며, 동일 게시물에 중복 요청할 수 없습니다.
     */
    public Reservation requestReservation(Long postId, String requesterUserId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("게시물을 찾을 수 없습니다. ID: " + postId));
        User requester = userRepository.findByUserId(requesterUserId)
                .orElseThrow(() -> new IllegalArgumentException("요청자 정보를 찾을 수 없습니다. ID: " + requesterUserId));
        User author = post.getUser();

        if (author.equals(requester)) {
            throw new IllegalStateException("자신의 게시물에는 예약 요청을 할 수 없습니다.");
        }

        reservationRepository.findByPostAndRequester(post, requester).ifPresent(existing -> {
            throw new IllegalStateException("이미 해당 게시물에 대한 예약 기록이 있습니다. 상태: " + existing.getStatus());
        });

        Reservation newReservation = Reservation.builder()
                .post(post)
                .requester(requester)
                .author(author)
                .status(ReservationStatus.REQUESTED)
                .build();
        return reservationRepository.save(newReservation);
    }

    /**
     * 예약을 수락합니다. (게시물 작성자만 가능)
     * 예약 상태가 REQUESTED일 때만 수락 가능합니다.
     */
    public Reservation acceptReservation(Long reservationId, String currentUserId) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new IllegalArgumentException("예약을 찾을 수 없습니다. ID: " + reservationId));
        User currentUser = userRepository.findByUserId(currentUserId)
                .orElseThrow(() -> new IllegalArgumentException("사용자 정보를 찾을 수 없습니다. ID: " + currentUserId));

        if (!reservation.getAuthor().equals(currentUser)) {
            throw new IllegalStateException("예약을 수락할 권한이 없습니다.");
        }
        if (reservation.getStatus() != ReservationStatus.REQUESTED) {
            throw new IllegalStateException("이미 처리되었거나 요청 상태가 아닌 예약입니다. 현재 상태: " + reservation.getStatus());
        }

        reservation.setStatus(ReservationStatus.ACCEPTED);
        // 선택 사항: 같은 게시물의 다른 REQUESTED 상태인 예약들을 REJECTED로 변경하는 로직
        return reservationRepository.save(reservation);
    }

    /**
     * 특정 게시물과 현재 사용자에 대한 예약 상태(정보)를 조회합니다.
     * ChatDetailScreen에서 "나의" 예약 상태를 확인할 때 사용됩니다.
     */
    @Transactional(readOnly = true)
    public Optional<Reservation> getReservationStatusForPostAndUser(Long postId, String currentUserId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("게시물을 찾을 수 없습니다. ID: " + postId));
        User currentUser = userRepository.findByUserId(currentUserId)
                .orElseThrow(() -> new IllegalArgumentException("사용자 정보를 찾을 수 없습니다. ID: " + currentUserId));
        return reservationRepository.findByPostAndUser(post, currentUser);
    }

    /**
     * 특정 게시물 ID에 해당하는 모든 예약 목록을 조회합니다.
     * ChatService에서 메시지 목록을 만들 때 예약 상태 아이콘 표시 등에 활용될 수 있습니다.
     */
    @Transactional(readOnly = true)
    public List<Reservation> getReservationsByPostId(Long postId) {
        return reservationRepository.findByPostId(postId);
    }


    /**
     * (선택 사항) 예약을 거절합니다. (게시물 작성자만 가능)
     * 예약 상태가 REQUESTED일 때만 거절 가능합니다.
     */
    public Reservation rejectReservation(Long reservationId, String currentUserId) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new IllegalArgumentException("예약을 찾을 수 없습니다. ID: " + reservationId));
        User currentUser = userRepository.findByUserId(currentUserId)
                .orElseThrow(() -> new IllegalArgumentException("사용자 정보를 찾을 수 없습니다. ID: " + currentUserId));

        if (!reservation.getAuthor().equals(currentUser)) {
            throw new IllegalStateException("예약을 거절할 권한이 없습니다.");
        }
        if (reservation.getStatus() != ReservationStatus.REQUESTED) {
            throw new IllegalStateException("이미 처리되었거나 요청 상태가 아닌 예약은 거절할 수 없습니다. 현재 상태: " + reservation.getStatus());
        }

        reservation.setStatus(ReservationStatus.REJECTED);
        return reservationRepository.save(reservation);
    }

    /**
     * (선택 사항) 예약을 취소합니다. (요청자 또는 게시물 작성자 가능)
     * 특정 상태(예: REQUESTED, ACCEPTED)의 예약만 취소 가능하도록 제한할 수 있습니다.
     */
    public Reservation cancelReservation(Long reservationId, String currentUserId) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new IllegalArgumentException("예약을 찾을 수 없습니다. ID: " + reservationId));
        User currentUser = userRepository.findByUserId(currentUserId)
                .orElseThrow(() -> new IllegalArgumentException("사용자 정보를 찾을 수 없습니다. ID: " + currentUserId));

        boolean canCancel = reservation.getRequester().equals(currentUser) || reservation.getAuthor().equals(currentUser);
        if (!canCancel) {
            throw new IllegalStateException("예약을 취소할 권한이 없습니다.");
        }

        // 예: REQUESTED 또는 ACCEPTED 상태일 때만 CANCELLED로 변경
        if (reservation.getStatus() == ReservationStatus.REQUESTED || reservation.getStatus() == ReservationStatus.ACCEPTED) {
            reservation.setStatus(ReservationStatus.CANCELLED);
            return reservationRepository.save(reservation);
        } else {
            throw new IllegalStateException("이미 최종 처리되었거나 취소할 수 없는 상태의 예약입니다. 현재 상태: " + reservation.getStatus());
        }
    }

    /**
     * (참고용) 예약 ID로 예약을 직접 조회하는 기본 메소드.
     * 주로 내부 로직이나 테스트에서 사용될 수 있습니다.
     */
    @Transactional(readOnly = true)
    public Optional<Reservation> findReservationById(Long reservationId) {
        return reservationRepository.findById(reservationId);
    }
}