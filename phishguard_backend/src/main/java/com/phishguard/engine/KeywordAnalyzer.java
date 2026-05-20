package com.phishguard.engine;

import lombok.*;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Analyzes URLs and content for suspicious keywords
 * common in phishing, KYC scams, OTP fraud etc.
 */
@Component
public class KeywordAnalyzer {

    private static final List<String> HIGH_RISK_KEYWORDS = Arrays.asList(
            "kyc-update", "kyc-expire", "kyc-verify", "kyc-pending",
            "otp-verify", "otp-confirm", "verify-otp",
            "account-blocked", "account-suspended", "account-freeze",
            "verify-now", "verify-account", "verify-identity",
            "update-immediately", "urgent-action", "immediate-action",
            "login-required", "re-login", "session-expired",
            "claim-reward", "claim-cashback", "claim-refund",
            "prize-winner", "lucky-draw", "free-recharge",
            "aadhaar-link", "pan-update", "pan-verify"
    );

    private static final List<String> MEDIUM_RISK_KEYWORDS = Arrays.asList(
            "kyc", "verify", "confirm", "update", "reward",
            "cashback", "refund", "alert", "warning", "expire",
            "bonus", "free", "offer", "limited", "exclusive"
    );

    public KeywordResult analyze(String text) {
        if (text == null) return new KeywordResult(0, new ArrayList<>());

        String lowerText = text.toLowerCase();
        int score = 0;
        List<String> reasons = new ArrayList<>();

        // Check high-risk keywords
        for (String keyword : HIGH_RISK_KEYWORDS) {
            if (lowerText.contains(keyword)) {
                score += 30;
                reasons.add("🔴 High-risk keyword detected: '" + keyword + "'");
                if (score >= 60) break; // Cap contribution
            }
        }

        // Check medium-risk keywords (only if not already high risk)
        if (score < 30) {
            int mediumCount = 0;
            for (String keyword : MEDIUM_RISK_KEYWORDS) {
                if (lowerText.contains(keyword)) {
                    mediumCount++;
                }
            }
            if (mediumCount >= 3) {
                score += 20;
                reasons.add("⚠️ Multiple suspicious keywords detected (" + mediumCount + " matches).");
            } else if (mediumCount >= 1) {
                score += 10;
                reasons.add("⚠️ Suspicious keyword detected in URL.");
            }
        }

        return new KeywordResult(Math.min(score, 60), reasons);
    }

    @Data
    @AllArgsConstructor
    public static class KeywordResult {
        private int score;
        private List<String> reasons;
    }
}
