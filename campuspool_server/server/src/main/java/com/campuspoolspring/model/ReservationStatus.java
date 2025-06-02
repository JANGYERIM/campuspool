package com.campuspoolspring.model; // 본인의 패키지 경로에 맞게 수정

public enum ReservationStatus {
    REQUESTED,  // 요청됨 (탑승자가 예약 요청)
    ACCEPTED,   // 수락됨 (운전자가 수락)
    // CONFIRMED, // 확정됨 (ACCEPTED와 동일하게 사용하거나, 별도 확정 단계가 있다면 추가)
    REJECTED,   // 거절됨 (운전자가 거절)
    CANCELLED   // 취소됨 (탑승자 또는 운전자가 취소)
}