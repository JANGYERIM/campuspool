package com.campuspoolspring.service; // 본인의 프로젝트 패키지 경로에 맞게 수정

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender; // Spring이 자동으로 주입해 줄 이메일 발송 객체

    // application.yml 또는 application.properties에서 spring.mail.username 값을 가져옴
    @Value("${spring.mail.username}")
    private String fromEmail; // 발신자 이메일 주소 (환경 변수로 설정한 Gmail 주소)

    // 건의사항을 받을 관리자 이메일 주소 (고정)
    private final String TO_ADMIN_EMAIL = "dpfla3573@naver.com";

    /**
     * 건의사항 내용을 관리자에게 이메일로 발송합니다.
     *
     * @param userEmail 건의를 보낸 사용자의 이메일 주소 (답장 받을 주소로 사용됨)
     * @param subject   건의사항 제목
     * @param content   건의사항 내용
     */
    public void sendSuggestionEmail(String userEmail, String subject, String content) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromEmail); // 실제 발신되는 이메일의 "보낸 사람" (설정한 Gmail 계정)
        message.setTo(TO_ADMIN_EMAIL); // 건의사항을 받을 관리자 이메일
        message.setReplyTo(userEmail); // 관리자가 "답장"을 누르면 이 주소로 답장하게 됨
        message.setSubject("[앱 건의사항] " + subject); // 메일 제목

        // 메일 본문 구성
        String emailBody = "보낸 사람 이메일: " + userEmail + "\n\n" +
                "제목: " + subject + "\n\n" +
                "내용:\n" + content;
        message.setText(emailBody);

        try {
            mailSender.send(message); // 메일 발송 실행
            System.out.println("건의사항 메일이 성공적으로 발송되었습니다. 받는사람: " + TO_ADMIN_EMAIL + ", 보낸사람(답장): " + userEmail);
        } catch (Exception e) {
            System.err.println("메일 발송 중 오류가 발생했습니다: " + e.getMessage());
            // 실제 운영 환경에서는 Log4j, SLF4j 등의 로깅 프레임워크를 사용하여 에러를 기록하는 것이 좋습니다.
            // e.printStackTrace(); // 개발 중에는 스택 트레이스를 출력하여 디버깅에 활용
            // 사용자에게 오류를 알리기 위해 커스텀 예외를 던지거나, 컨트롤러에서 처리할 수 있도록 예외를 다시 던질 수 있습니다.
            throw new RuntimeException("메일 발송 처리 중 문제가 발생했습니다.", e);
        }
    }
}