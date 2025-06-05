package com.campuspoolspring.controller; // 본인의 프로젝트 패키지 경로에 맞게 수정

import com.campuspoolspring.Dto.SuggestionRequestDto; // 이전에 만든 DTO
import com.campuspoolspring.model.User; // User 모델 클래스 (Spring Security와 연동 시 필요)
import com.campuspoolspring.service.EmailService;    // 방금 만든 EmailService
import jakarta.validation.Valid; // Spring Boot 3.x 이상 Validation
// import javax.validation.Valid; // Spring Boot 2.x 이하 Validation
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication; // Spring Security 사용 시 필요
import org.springframework.security.core.userdetails.UserDetails; // UserDetails 사용 시
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.campuspoolspring.model.User;

@RestController
@RequestMapping("/api/suggestions")
public class SuggestionController {

    @Autowired
    private EmailService emailService;

    @PostMapping
    public ResponseEntity<String> submitSuggestion(
            @Valid @RequestBody SuggestionRequestDto suggestionDto,
            Authentication authentication
    ) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).body("접근 권한이 없습니다. 로그인이 필요합니다.");
        }

        String userEmail;
        Object principal = authentication.getPrincipal(); // Principal 객체를 가져옵니다.

        // JwtAuthenticationFilter에서 User 객체를 Principal로 설정했으므로,
        // principal은 com.campuspoolspring.model.User 타입의 인스턴스여야 합니다.
        if (principal instanceof com.campuspoolspring.model.User) {
            // User 객체로 캐스팅한 후, getEmail() 메소드를 호출합니다.
            // (User 클래스에 getEmail() 메소드가 정의되어 있어야 합니다.)
            userEmail = ((com.campuspoolspring.model.User) principal).getEmail();
        } else {
            // 예상치 못한 타입의 Principal이 온 경우 (디버깅용 로그)
            System.err.println("예상치 못한 Principal 타입입니다: " + principal.getClass().getName());
            System.err.println("Principal 값: " + principal.toString());
            // UserDetails를 사용하는 경우를 대비한 폴백 (만약 User가 UserDetails를 구현한다면)
            if (principal instanceof org.springframework.security.core.userdetails.UserDetails) {
                userEmail = ((org.springframework.security.core.userdetails.UserDetails) principal).getUsername();
                if (userEmail == null || userEmail.isEmpty()){
                    return ResponseEntity.status(500).body("서버 오류: 사용자 이메일 정보를 UserDetails에서 가져올 수 없습니다.");
                }
            } else {
                return ResponseEntity.status(500).body("서버 오류: 사용자 정보를 처리할 수 없습니다.");
            }
        }

        if (userEmail == null || userEmail.isEmpty()) {
            return ResponseEntity.status(400).body("사용자의 이메일 정보를 가져올 수 없습니다.");
        }

        try {
            emailService.sendSuggestionEmail(userEmail, suggestionDto.getSubject(), suggestionDto.getContent());
            return ResponseEntity.ok("건의사항이 성공적으로 접수되었습니다.");
        } catch (RuntimeException e) {
            System.err.println("건의사항 처리 중 컨트롤러에서 오류 발생: " + e.getMessage());
            return ResponseEntity.status(500).body("건의사항 처리 중 서버 내부 오류가 발생했습니다.");
        }
    }
}