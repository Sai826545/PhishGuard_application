package com.phishguard.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "scan_history")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScanHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "scan_type", nullable = false, length = 20)
    private ScanType scanType;

    @Column(name = "scanned_content", columnDefinition = "TEXT", nullable = false)
    private String scannedContent;

    @Enumerated(EnumType.STRING)
    @Column(name = "result_status", nullable = false, length = 20)
    private ResultStatus resultStatus;

    @Column(name = "risk_score")
    private Integer riskScore;

    @Column(name = "domain_name")
    private String domainName;

    @Column(name = "ssl_status")
    private Boolean sslStatus;

    @Column(name = "redirect_count")
    private Integer redirectCount;

    @Column(name = "domain_age_days")
    private Integer domainAgeDays;

    @Column(name = "ai_reasons", columnDefinition = "TEXT")
    private String aiReasons;

    @CreationTimestamp
    @Column(name = "scanned_at", updatable = false)
    private LocalDateTime scannedAt;

    public enum ScanType {
        URL, QR, SMS, EMAIL
    }

    public enum ResultStatus {
        SAFE, SUSPICIOUS, DANGEROUS
    }
}
