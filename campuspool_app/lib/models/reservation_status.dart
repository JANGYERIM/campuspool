// lib/models/reservation_status.dart

enum ReservationStatus {
  REQUESTED,  // 요청됨
  ACCEPTED,   // 수락됨
  REJECTED,   // 거절됨
  CANCELLED,  // 취소됨
  NONE,       // 관련 예약 없음 (클라이언트에서 사용하기 위한 상태 또는 서버에서 명시적으로 줄 경우)
  UNKNOWN     // 파싱 실패 또는 알 수 없는 상태
}

ReservationStatus reservationStatusFromString(String? statusString) {
  if (statusString == null || statusString.isEmpty) {
    return ReservationStatus.NONE; // 또는 ReservationStatus.UNKNOWN 등 기본값
  }
  switch (statusString.toUpperCase()) {
    case 'REQUESTED':
      return ReservationStatus.REQUESTED;
    case 'ACCEPTED':
      return ReservationStatus.ACCEPTED;
    case 'REJECTED':
      return ReservationStatus.REJECTED;
    case 'CANCELLED':
      return ReservationStatus.CANCELLED;
    case 'NONE': // 서버에서 "NONE"으로 명시적으로 줄 경우
      return ReservationStatus.NONE;
    default:
      print('Unknown reservation status string: $statusString');
      return ReservationStatus.UNKNOWN;
  }
}