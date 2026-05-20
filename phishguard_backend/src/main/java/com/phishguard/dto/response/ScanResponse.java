package com.phishguard.dto.response;

import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ScanResponse {
    private Long historyId;
    private String scanType;
    private String scannedContent;
    private String resultStatus;    // SAFE, SUSPICIOUS, DANGEROUS
    private int riskScore;          // 0–100
    private String domainName;
    private boolean sslStatus;
    private int redirectCount;
    private int domainAgeDays;
    private boolean blacklisted;
    private boolean trusted;
    private List<String> aiReasons; // Explainable AI reasons
    private LocalDateTime scannedAt;
}
