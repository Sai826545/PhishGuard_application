package com.phishguard.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "users", uniqueConstraints = {
        @UniqueConstraint(columnNames = "username"),
        @UniqueConstraint(columnNames = "email")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 50)
    private String username;

    @Column(nullable = false, length = 100)
    private String email;

    @JsonIgnore
    @Column(nullable = false)
    private String password;

    @Column(name = "total_scans")
    @Builder.Default
    private Integer totalScans = 0;

    @Column(name = "blocked_threats")
    @Builder.Default
    private Integer blockedThreats = 0;

    @Column(name = "preferred_language", length = 10)
    @Builder.Default
    private String preferredLanguage = "en";

    @Column(name = "profile_image_url")
    private String profileImageUrl;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
