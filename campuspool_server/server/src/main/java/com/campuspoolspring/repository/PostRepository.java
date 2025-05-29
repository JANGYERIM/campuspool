package com.campuspoolspring.repository;

import java.util.List;
import com.campuspoolspring.model.Post;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PostRepository extends JpaRepository<Post, Long> {
    List<Post> findByDriver(boolean driver);

}

