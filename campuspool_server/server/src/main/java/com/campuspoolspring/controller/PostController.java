package com.campuspoolspring.controller;

import com.campuspoolspring.model.Post;
import com.campuspoolspring.model.User;
import com.campuspoolspring.service.PostService;
import com.campuspoolspring.service.UserService;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;


@RestController
@RequestMapping("/api/posts")
public class PostController {
    @Autowired
    private PostService postService;

    @Autowired
    private UserService userService;

    // 게시물 등록
    @PostMapping
    public ResponseEntity<?> createPost(@RequestBody PostRequest request, Authentication authentication) {
        User user = (User) authentication.getPrincipal();
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("유저 정보가 없습니다.");
        }

        Post post = Post.builder()
                .user(user)
                .date(request.getDate())
                .departure(request.getDeparture())
                .destination(request.getDestination())
                .departureTime(request.getDepartureTime())
                .arrivalTime(request.getArrivalTime())
                .fare(request.getFare())
                .detail(request.getDetail())
                .driver(request.isDriver()) // 작성자 역할 저장
                .build();
        return ResponseEntity.ok(postService.save(post));
    }

    // 게시물 목록 조회 (간략 정보)
    @GetMapping("/api/posts")
    public ResponseEntity<List<PostSummary>> getAllPosts() {
        List<Post> posts = postService.findAll();
        List<PostSummary> summaries = posts.stream().map(PostSummary::from).toList();

        return ResponseEntity
                .ok()
                .header("Content-Type", "application/json; charset=UTF-8")
                .body(summaries);
    }


    // 게시물 상세 조회
    @GetMapping("/{id}")
    public ResponseEntity<PostDetailResponse> getPost(@PathVariable Long id) {
        Post post = postService.findById(id);
        if (post == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(PostDetailResponse.from(post));
    }

    // 탭에 따라 반대 역할 게시물 조회
    @GetMapping("/by-role")
    public List<PostSummary> getPostsForOppositeRole(@RequestParam boolean viewerIsDriver) {
        List<Post> posts = postService.findByOppositeRole(viewerIsDriver);
        return posts.stream().map(PostSummary::from).toList();
    }

    @Data
    public static class PostRequest {
        private LocalDate date;
        private String departure;
        private String destination;
        private LocalTime departureTime;
        private LocalTime arrivalTime;
        private String fare;
        private String detail;
        private boolean driver; // 작성자가 운전자인지 여부
    }

    @Data
    public static class PostSummary {
        private Long id;
        private String departure;
        private String destination;
        private String nickname;
        private LocalDate date;
        private LocalTime departureTime;
        private LocalTime arrivalTime;
        private String fare;

        public static PostSummary from(Post post) {
            PostSummary summary = new PostSummary();
            summary.setId(post.getId());
            summary.setDeparture(post.getDeparture());
            summary.setDestination(post.getDestination());
            String nickname = post.getUser().getNickname();
            summary.setNickname(nickname != null && !nickname.isEmpty() ? nickname : "익명");
            summary.setDate(post.getDate());
            summary.setDepartureTime(post.getDepartureTime());
            summary.setArrivalTime(post.getArrivalTime());
            summary.setFare(post.getFare());
            return summary;
        }
    }
}
