package com.phishguard.engine;

import lombok.*;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * India-specific threat detection module.
 * Covers: Fake banks, UPI scams, KYC fraud,
 * government portal impersonation, courier scams.
 */
@Component
public class IndiaSpecificDetector {

    // Fake bank domain patterns
    private static final List<String> BANK_KEYWORDS = Arrays.asList(
            "sbi", "hdfc", "icici", "axis", "kotak", "yesbank",
            "pnb", "bob", "boi", "canara", "union-bank", "idbi"
    );

    // Suspicious bank-related URL keywords (NOT in official domains)
    private static final List<String> BANK_SCAM_KEYWORDS = Arrays.asList(
            "kyc-update", "netbanking-secure", "online-banking-login",
            "account-freeze", "sbi-reward", "hdfc-cashback",
            "bank-alert", "banking-verify", "bank-kyc"
    );

    // Government portal impersonation patterns
    private static final List<String> GOVT_SCAM_PATTERNS = Arrays.asList(
            "aadhaar-update", "aadhaar-link", "aadhaar-refund",
            "pan-verify", "pan-apply", "pan-card-update",
            "incometax-refund", "income-tax-claim",
            "passport-renew", "pm-kisan", "epf-withdraw",
            "subsidy-claim", "govt-scheme"
    );

    // Courier scam patterns
    private static final List<String> COURIER_SCAM_PATTERNS = Arrays.asList(
            "parcel-pending", "delivery-failed", "customs-fee",
            "shipment-hold", "package-undelivered", "delivery-charge",
            "delhivery-track", "bluedart-update", "indiapost-parcel",
            "dtdc-shipment", "fedex-delivery-alert"
    );

    // UPI scam patterns
    private static final List<String> UPI_SCAM_PATTERNS = Arrays.asList(
            "upi-refund", "upi-cashback", "bhim-reward",
            "upi-prize", "pay-fine-upi", "upi-verify",
            "paytm-reward-claim", "phonepe-cashback-now",
            "googlepay-claim", "gpay-offer"
    );

    // Legitimate bank domain suffixes
    private static final Map<String, String> LEGIT_BANK_DOMAINS = Map.of(
            "sbi", "sbi.co.in",
            "hdfc", "hdfcbank.com",
            "icici", "icicibank.com",
            "axis", "axisbank.com",
            "kotak", "kotak.com"
    );

    public IndiaResult analyze(String url, String domain) {
        int score = 0;
        List<String> reasons = new ArrayList<>();

        String lowerUrl = url.toLowerCase();
        String lowerDomain = domain.toLowerCase();

        // 1. Fake bank domain detection
        for (String bank : BANK_KEYWORDS) {
            if (lowerDomain.contains(bank)) {
                // Check if it's legitimate
                String legitDomain = LEGIT_BANK_DOMAINS.get(bank);
                if (legitDomain == null || (!lowerDomain.equals(legitDomain) && !lowerDomain.endsWith("." + legitDomain))) {
                    score += 45;
                    reasons.add("🔴 Fake " + bank.toUpperCase() + " domain detected — impersonating official bank website.");
                    break;
                }
            }
        }

        // 2. Bank scam keywords in URL
        for (String kw : BANK_SCAM_KEYWORDS) {
            if (lowerUrl.contains(kw)) {
                score += 30;
                reasons.add("⚠️ Bank scam keyword detected: '" + kw + "'");
                break;
            }
        }

        // 3. Government portal scam
        for (String pattern : GOVT_SCAM_PATTERNS) {
            if (lowerUrl.contains(pattern)) {
                score += 35;
                reasons.add("🔴 Fake government portal pattern: '" + pattern + "' — possible Aadhaar/PAN/income tax scam.");
                break;
            }
        }

        // 4. Courier scam
        for (String pattern : COURIER_SCAM_PATTERNS) {
            if (lowerUrl.contains(pattern)) {
                score += 30;
                reasons.add("⚠️ Courier fraud pattern detected: '" + pattern + "' — fake delivery notification scam.");
                break;
            }
        }

        // 5. UPI scam
        for (String pattern : UPI_SCAM_PATTERNS) {
            if (lowerUrl.contains(pattern)) {
                score += 35;
                reasons.add("🔴 UPI scam pattern detected: '" + pattern + "' — never pay via unverified QR/links.");
                break;
            }
        }

        // 6. KYC scam
        if (lowerUrl.contains("kyc") && (lowerUrl.contains("expire") || lowerUrl.contains("update") || lowerUrl.contains("verify"))) {
            score += 40;
            reasons.add("🔴 KYC scam detected — banks/UIDAI never ask you to update KYC via SMS links.");
        }

        return new IndiaResult(Math.min(score, 55), reasons);
    }

    @Data
    @AllArgsConstructor
    public static class IndiaResult {
        private int score;
        private List<String> reasons;
    }
}
