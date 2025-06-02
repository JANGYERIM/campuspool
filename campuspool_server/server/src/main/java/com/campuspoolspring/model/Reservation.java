package com.campuspoolspring.model; // 본인의 패키지 경로에 맞게 수정

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "reservations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY) // 지연 로딩으로 설정하여 성능 최적화
    @JoinColumn(name = "post_id", nullable = false)
    private Post post; // 예약과 연결된 게시물

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "requester_id", nullable = false)
    private User requester; // 예약을 요청한 사용자 (탑승자)

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    private User author; // 게시물 작성자 (운전자)

    @Enumerated(EnumType.STRING) // Enum 값을 문자열로 DB에 저장
    @Column(nullable = false)
    private ReservationStatus status;

    @CreationTimestamp // 엔티티 생성 시 자동으로 현재 시간 저장
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp // 엔티티 수정 시 자동으로 현재 시간 저장
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    // 추가적으로 필요한 정보가 있다면 필드 추가 가능
    // 예: private String requestMessage; // 요청 메시지
    // 예: private LocalDateTime confirmedAt; // 확정 시간
}
