package com.campuspoolspring.controller;

import com.campuspoolspring.model.Reservation;
import com.campuspoolspring.model.User;
import com.campuspoolspring.service.ReservationService;
// import lombok.Data; // 이 컨트롤러에서는 DTO를 직접 사용하지 않으므로 제거 가능
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
// import org.springframework.security.core.userdetails.UsernameNotFoundException; // 직접 사용하지 않으면 제거 가능
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/reservations")
public class ReservationController {

    private final ReservationService reservationService;

    @Autowired
    public ReservationController(ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    /**
     * 새로운 예약을 요청합니다.
     * 요청 본문에는 "postId"가 Long 타입으로 포함되어야 합니다.
     */
    @PostMapping
    public ResponseEntity<?> requestReservation(@RequestBody Map<String, Long> payload, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || !(authentication.getPrincipal() instanceof User)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "로그인이 필요합니다."));
        }
        User requester = (User) authentication.getPrincipal();
        Long postId = payload.get("postId");

        if (postId == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "postId는 필수입니다."));
        }

        try {
            Reservation reservation = reservationService.requestReservation(postId, requester.getUserId());
            return ResponseEntity.status(HttpStatus.CREATED).body(reservation);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", "예약 요청 중 오류가 발생했습니다."));
        }
    }

    /**
     * 예약을 수락합니다. (게시물 작성자만 가능)
     * {reservationId}는 수락할 예약의 ID입니다.
     */
    @PutMapping("/{reservationId}/accept")
    public ResponseEntity<?> acceptReservation(@PathVariable Long reservationId, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || !(authentication.getPrincipal() instanceof User)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "로그인이 필요합니다."));
        }
        User currentUser = (User) authentication.getPrincipal();

        try {
            Reservation reservation = reservationService.acceptReservation(reservationId, currentUser.getUserId());
            return ResponseEntity.ok(reservation);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", "예약 수락 중 오류가 발생했습니다."));
        }
    }

    /**
     * 특정 게시물에 대한 현재 사용자의 예약 상태(정보)를 조회합니다.
     * postId는 쿼리 파라미터로 전달받습니다.
     */
    @GetMapping("/status")
    public ResponseEntity<Object> getReservationStatus(@RequestParam Long postId, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || !(authentication.getPrincipal() instanceof User)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "로그인이 필요합니다."));
        }
        User currentUser = (User) authentication.getPrincipal();

        try {
            Optional<Reservation> reservationOpt = reservationService.getReservationStatusForPostAndUser(postId, currentUser.getUserId());

            return reservationOpt
                    .<ResponseEntity<Object>>map(ResponseEntity::ok) // Reservation 객체를 그대로 반환
                    .orElseGet(() -> ResponseEntity.ok().body(Map.of("status", "NOT_REQUESTED", "message", "해당 게시물에 대한 예약 요청이 없습니다.")));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", "예약 상태 조회 중 오류가 발생했습니다."));
        }
    }

    /**
     * (선택) 예약을 거절합니다. (게시물 작성자만 가능)
     */
    @PutMapping("/{reservationId}/reject")
    public ResponseEntity<?> rejectReservation(@PathVariable Long reservationId, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || !(authentication.getPrincipal() instanceof User)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "로그인이 필요합니다."));
        }
        User currentUser = (User) authentication.getPrincipal();

        try {
            Reservation reservation = reservationService.rejectReservation(reservationId, currentUser.getUserId());
            return ResponseEntity.ok(reservation);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", "예약 거절 중 오류가 발생했습니다."));
        }
    }

    /**
     * (선택) 예약을 취소합니다. (요청자 또는 게시물 작성자 가능)
     */
    @PutMapping("/{reservationId}/cancel")
    public ResponseEntity<?> cancelReservation(@PathVariable Long reservationId, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || !(authentication.getPrincipal() instanceof User)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "로그인이 필요합니다."));
        }
        User currentUser = (User) authentication.getPrincipal();

        try {
            Reservation reservation = reservationService.cancelReservation(reservationId, currentUser.getUserId());
            return ResponseEntity.ok(reservation);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", "예약 취소 중 오류가 발생했습니다."));
        }
    }
}