package com.campuspoolspring.Dto;

import lombok.Getter;
import lombok.Setter;
import jakarta.validation.constraints.NotBlank; // Spring Boot 3.x 이상 사용 시
// import javax.validation.constraints.NotBlank; // Spring Boot 2.x 이하 사용 시

@Getter
@Setter
public class SuggestionRequestDto {

    @NotBlank(message = "제목은 필수 입력 항목입니다.") // 유효성 검증: 비어있을 수 없음
    private String subject; // 건의사항 제목을 담을 필드

    @NotBlank(message = "내용은 필수 입력 항목입니다.") // 유효성 검증: 비어있을 수 없음
    private String content; // 건의사항 내용을 담을 필드
}