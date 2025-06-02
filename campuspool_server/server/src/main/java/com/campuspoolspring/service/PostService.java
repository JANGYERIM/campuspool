package com.campuspoolspring.service;

import com.campuspoolspring.model.Post;
import com.campuspoolspring.repository.PostRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Collections;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PostService {
    @Autowired
    private PostRepository postRepository;

    @Transactional
    public Post save(Post post) {
        return postRepository.save(post);
    }

    @Transactional(readOnly = true) // 데이터 조회만 하므로 readOnly = true 추가 (성능 향상)
    public List<Post> findAll() {
        return postRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Post findById(Long id) {
        return postRepository.findById(id).orElse(null);
    }

    public List<Post> findByOppositeRole(boolean isCurrentUserDriver) {
        return postRepository.findByDriver(!isCurrentUserDriver); // ❗반대로 조회
    }

    @Transactional(readOnly = true)
    public List<Post> searchPostsByKeyword(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return Collections.emptyList();
            // 또는 return findAll(); // 전체 목록 반환을 원한다면
        }

        String searchKeyword = keyword.trim();
        // PostRepository에 정의된 검색 메소드 호출
        List<Post> posts = postRepository.findByKeywordInDepartureOrDestinationOrUserNickname(searchKeyword);

        return posts;

    }
}