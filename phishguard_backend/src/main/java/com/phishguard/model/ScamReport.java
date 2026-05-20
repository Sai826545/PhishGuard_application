package com.phishguard.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "scam_reports")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScamReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private Category category;

    @Column(columnDefinition = "TEXT")
    private String content;

    @Column(name = "screenshot_url", length = 500)
    private String screenshotUrl;

    @Column(length = 20)
    private String phoneNumber;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private Status status = Status.PENDING;

    @CreationTimestamp
    @Column(name = "reported_at", updatable = false)
    private LocalDateTime reportedAt;

    public enum Category {
        BANK_SCAM, UPI_SCAM, COURIER_SCAM, GOVT_SCAM, SMS_SCAM, EMAIL_SCAM, OTHER
    }

    public enum Status {
        PENDING, REVIEWED, RESOLVED
    }
}
