package com.campuspoolspring.service;

import com.campuspoolspring.model.Post;
import com.campuspoolspring.repository.PostRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class PostService {
    @Autowired
    private PostRepository postRepository;

    public Post save(Post post) {
        return postRepository.save(post);
    }

    public List<Post> findAll() {
        return postRepository.findAll();
    }

    public Post findById(Long id) {
        return postRepository.findById(id).orElse(null);
    }

    public List<Post> findByOppositeRole(boolean isCurrentUserDriver) {
        return postRepository.findByDriver(!isCurrentUserDriver); // ❗반대로 조회
    }

}