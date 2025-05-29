package com.campuspoolspring.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "posts")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
public class Post {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    private LocalDate date;
    private String departure;
    private String destination;
    private LocalTime departureTime;
    private LocalTime arrivalTime;
    private String fare; // int → String
    private String detail;
    private boolean driver;
}