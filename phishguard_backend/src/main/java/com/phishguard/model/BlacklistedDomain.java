package com.phishguard.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "blacklisted_domains")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BlacklistedDomain {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String domain;

    @Column(length = 100)
    private String category;

    @Column(name = "added_at")
    @CreationTimestamp
    private LocalDateTime addedAt;
}
