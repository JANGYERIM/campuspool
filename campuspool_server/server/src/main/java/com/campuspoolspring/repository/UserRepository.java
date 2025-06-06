package com.campuspoolspring.repository;

import com.campuspoolspring.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email); // 이메일 중복 확인용

    Optional<User> findByUserId(String userId);
}