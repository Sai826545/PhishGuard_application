package com.phishguard.engine;

import lombok.*;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class DetectionResult {

    private int riskScore;
    private String status;           // SAFE, SUSPICIOUS, DANGEROUS
    private String domainName;
    private boolean sslStatus;
    private int redirectCount;
    private int domainAgeDays;
    private boolean blacklisted;
    private boolean trusted;
    private List<String> reasons;    // AI Explanation reasons

    public static String scoreToStatus(int score) {
        if (score <= 30) return "SAFE";
        if (score <= 60) return "SUSPICIOUS";
        return "DANGEROUS";
    }
}
