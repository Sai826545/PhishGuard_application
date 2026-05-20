package com.phishguard.engine;

import lombok.*;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * Detects typosquatted domains impersonating real brands.
 * Checks for character substitution (o→0, i→1, l→1),
 * added prefixes/suffixes, and edit distance.
 */
@Component
public class TyposquatDetector {

    private static final Map<String, String> BRAND_DOMAINS = new LinkedHashMap<>();

    static {
        // Indian Banks
        BRAND_DOMAINS.put("sbi", "SBI (State Bank of India)");
        BRAND_DOMAINS.put("hdfc", "HDFC Bank");
        BRAND_DOMAINS.put("icici", "ICICI Bank");
        BRAND_DOMAINS.put("axis", "Axis Bank");
        BRAND_DOMAINS.put("kotak", "Kotak Mahindra Bank");
        BRAND_DOMAINS.put("yesbank", "Yes Bank");
        BRAND_DOMAINS.put("pnb", "Punjab National Bank");
        BRAND_DOMAINS.put("uidai", "UIDAI (Aadhaar)");
        BRAND_DOMAINS.put("incometax", "Income Tax India");
        BRAND_DOMAINS.put("paytm", "Paytm");
        BRAND_DOMAINS.put("phonepe", "PhonePe");
        BRAND_DOMAINS.put("amazon", "Amazon");
        BRAND_DOMAINS.put("flipkart", "Flipkart");
        BRAND_DOMAINS.put("irctc", "IRCTC");
        BRAND_DOMAINS.put("delhivery", "Delhivery");
        BRAND_DOMAINS.put("indiapost", "India Post");
        BRAND_DOMAINS.put("google", "Google");
        BRAND_DOMAINS.put("facebook", "Facebook");
        BRAND_DOMAINS.put("whatsapp", "WhatsApp");
    }

    // Common character substitutions used in typosquatting
    private static final Map<Character, Character> LEET_MAP = Map.of(
            '0', 'o', '1', 'i', '3', 'e', '4', 'a', '5', 's', '@', 'a'
    );

    public TyposquatResult detect(String domain) {
        if (domain == null) return new TyposquatResult(false, null);

        String normalizedDomain = normalizeDomain(domain);

        for (Map.Entry<String, String> entry : BRAND_DOMAINS.entrySet()) {
            String brand = entry.getKey();
            String brandName = entry.getValue();

            // Direct brand presence in domain (but not the legitimate TLD)
            if (containsBrandKeyword(normalizedDomain, brand)) {
                // Check if it's a legitimate brand domain
                if (!isLegitimate(domain, brand)) {
                    return new TyposquatResult(true, brandName);
                }
            }

            // Edit distance check (catches amaz0n, g00gle etc.)
            if (editDistance(normalizedDomain.split("\\.")[0], brand) <= 2
                    && !normalizedDomain.split("\\.")[0].equals(brand)) {
                return new TyposquatResult(true, brandName);
            }
        }

        return new TyposquatResult(false, null);
    }

    private String normalizeDomain(String domain) {
        StringBuilder sb = new StringBuilder(domain.toLowerCase());
        for (int i = 0; i < sb.length(); i++) {
            Character replacement = LEET_MAP.get(sb.charAt(i));
            if (replacement != null) {
                sb.setCharAt(i, replacement);
            }
        }
        return sb.toString();
    }

    private boolean containsBrandKeyword(String domain, String brand) {
        return domain.contains(brand);
    }

    private boolean isLegitimate(String domain, String brand) {
        Map<String, List<String>> legit = Map.of(
                "sbi", List.of("sbi.co.in", "onlinesbi.sbi"),
                "hdfc", List.of("hdfcbank.com"),
                "icici", List.of("icicibank.com"),
                "paytm", List.of("paytm.com"),
                "google", List.of("google.com", "google.co.in"),
                "amazon", List.of("amazon.in", "amazon.com")
        );
        List<String> legitimateDomains = legit.getOrDefault(brand, List.of());
        return legitimateDomains.stream().anyMatch(d -> domain.equals(d) || domain.endsWith("." + d));
    }

    // Levenshtein distance
    private int editDistance(String s1, String s2) {
        int m = s1.length(), n = s2.length();
        int[][] dp = new int[m + 1][n + 1];
        for (int i = 0; i <= m; i++) dp[i][0] = i;
        for (int j = 0; j <= n; j++) dp[0][j] = j;
        for (int i = 1; i <= m; i++) {
            for (int j = 1; j <= n; j++) {
                if (s1.charAt(i - 1) == s2.charAt(j - 1)) {
                    dp[i][j] = dp[i - 1][j - 1];
                } else {
                    dp[i][j] = 1 + Math.min(dp[i - 1][j - 1], Math.min(dp[i - 1][j], dp[i][j - 1]));
                }
            }
        }
        return dp[m][n];
    }

    @Data
    @AllArgsConstructor
    public static class TyposquatResult {
        private boolean suspicious;
        private String brand;
    }
}
