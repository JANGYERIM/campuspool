package com.campuspoolspring.controller;

import com.campuspoolspring.model.User;
import com.campuspoolspring.service.UserService;
import com.campuspoolspring.security.JwtUtil; // JwtUtil import
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired
    private UserService userService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    // 회원가입
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User user) {
        if (userService.existsByEmail(user.getEmail())) {
            System.out.println("로그인 시도 - 이메일: " + user.getEmail() + ", 비밀번호: " + user.getPassword());
            System.out.println("이미 존재하는 이메일입니다.");
            return ResponseEntity.badRequest().body("이미 존재하는 이메일입니다.");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        User savedUser = userService.register(user);
        return ResponseEntity.ok(savedUser);
    }

    // 로그인 (이메일+비밀번호)
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        Optional<User> userOpt = userService.findByEmail(request.getEmail());
        if (userOpt.isEmpty()) {
            System.out.println("로그인 시도 - 이메일: " + request.getEmail() + ", 비밀번호: " + request.getPassword());
            System.out.println("이메일 또는 비밀번호가 올바르지 않습니다.");
            return ResponseEntity.badRequest().body("이메일 또는 비밀번호가 올바르지 않습니다.");
        }
        User user = userOpt.get();
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            System.out.println("로그인 시도 - 이메일: " + request.getEmail() + ", 비밀번호: " + request.getPassword());
            System.out.println("이메일 또는 비밀번호가 올바르지 않습니다.");
            return ResponseEntity.badRequest().body("이메일 또는 비밀번호가 올바르지 않습니다.");
        }
        String token = jwtUtil.generateToken(user.getEmail());
        System.out.println("로그인 시도 - 이메일: " + request.getEmail() + ", 비밀번호: " + request.getPassword());
        System.out.println("로그인되었습니다.");
        return ResponseEntity.ok(Map.of("token", token,  "userId", user.getUserId()));
    }

    // 이메일 중복 확인
    @GetMapping("/check-email")
    public ResponseEntity<?> checkEmail(@RequestParam String email) {
        boolean exists = userService.existsByEmail(email);
        return ResponseEntity.ok(Map.of("exists", exists));
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getProfile(@RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.replace("Bearer ", "");
            String email = jwtUtil.getEmailFromToken(token); // 이메일을 토큰에서 추출

            Optional<User> userOpt = userService.findByEmail(email);
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(404).body("사용자 정보를 찾을 수 없습니다.");
            }

            User user = userOpt.get();

            // 민감한 정보 제거하고 필요한 것만 보내기
            Map<String, Object> profile = Map.of(
                    "email", user.getEmail(),
                    "name", user.getName(),
                    "phoneNumber", user.getPhoneNumber(),
                    "nickname", user.getNickname() != null && !user.getNickname().isEmpty() ? user.getNickname() : "익명"
            );

            return ResponseEntity.ok(profile);
        } catch (Exception e) {
            return ResponseEntity.status(401).body("토큰이 유효하지 않습니다.");
        }
    }

    @PutMapping("/update")
    public ResponseEntity<?> updateNickname(@RequestHeader("Authorization") String authHeader,
                                            @RequestBody Map<String, String> payload) {
        try {
            String token = authHeader.replace("Bearer ", "");
            String email = jwtUtil.getEmailFromToken(token); // 토큰에서 이메일 추출

            Optional<User> userOpt = userService.findByEmail(email);
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(404).body("사용자 정보를 찾을 수 없습니다.");
            }

            User user = userOpt.get();
            String newNickname = payload.get("nickname");
            user.setNickname(newNickname);
            userService.save(user);  // 저장

            return ResponseEntity.ok(Map.of("nickname", newNickname));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("닉네임 수정 중 오류 발생");
        }
    }



    @Data
    static class LoginRequest {
        private String email;
        private String password;
    }
}
