package com.campuspoolspring.controller;

import com.campuspoolspring.model.Post;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@AllArgsConstructor
public class PostDetailResponse {
    private Long id;
    private String departure;
    private String destination;
    private String nickname;
    private LocalDate date;
    private LocalTime departureTime;
    private LocalTime arrivalTime;
    private String fare;
    private String detail;
    private String userId;

    public static PostDetailResponse from(Post post) {
        return new PostDetailResponse(
                post.getId(),
                post.getDeparture(),
                post.getDestination(),
                post.getUser().getNickname(),
                post.getDate(),
                post.getDepartureTime(),
                post.getArrivalTime(),
                post.getFare(),
                post.getDetail(),
                post.getUser().getUserId()
        );
    }
}
