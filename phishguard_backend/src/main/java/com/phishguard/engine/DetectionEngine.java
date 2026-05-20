package com.phishguard.engine;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

/**
 * Main orchestrator for URL/QR/SMS/Email threat detection.
 * Rule-based engine — structured for ML integration later.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class DetectionEngine {

    private final BlacklistChecker blacklistChecker;
    private final TrustedDomainChecker trustedDomainChecker;
    private final TyposquatDetector typosquatDetector;
    private final KeywordAnalyzer keywordAnalyzer;
    private final SslChecker sslChecker;
    private final UrlShortenerDetector shortenerDetector;
    private final IndiaSpecificDetector indiaSpecificDetector;

    public DetectionResult analyze(String input) {
        List<String> reasons = new ArrayList<>();
        int score = 0;

        String url = sanitizeInput(input);
        String domain = extractDomain(url);

        // 1. Trusted domain check (early exit with reduction)
        if (trustedDomainChecker.isTrusted(domain)) {
            reasons.add("✅ Domain is a verified trusted website.");
            score = Math.max(0, score - 50);
            return buildResult(score, domain, reasons, true, false, url);
        }

        // 2. Blacklist check
        BlacklistChecker.BlacklistResult blacklist = blacklistChecker.check(domain, url);
        if (blacklist.isBlacklisted()) {
            score += 60;
            reasons.add("🔴 Domain is on the PhishGuard blacklist: " + blacklist.getCategory());
        }

        // 3. Typosquatting detection
        TyposquatDetector.TyposquatResult typosquat = typosquatDetector.detect(domain);
        if (typosquat.isSuspicious()) {
            score += 50;
            reasons.add("⚠️ Typosquatted domain detected: impersonating " + typosquat.getBrand());
        }

        // 4. India-specific detection
        IndiaSpecificDetector.IndiaResult india = indiaSpecificDetector.analyze(url, domain);
        score += india.getScore();
        reasons.addAll(india.getReasons());

        // 5. Keyword analysis
        KeywordAnalyzer.KeywordResult keywords = keywordAnalyzer.analyze(url);
        score += keywords.getScore();
        reasons.addAll(keywords.getReasons());

        // 6. SSL check
        if (!sslChecker.isHttps(url)) {
            score += 20;
            reasons.add("⚠️ URL uses insecure HTTP (no SSL/TLS encryption).");
        }

        // 7. IP address URL
        if (isIpBasedUrl(url)) {
            score += 35;
            reasons.add("🔴 URL uses an IP address instead of a domain name — highly suspicious.");
        }

        // 8. URL shortener
        if (shortenerDetector.isShortened(domain)) {
            score += 15;
            reasons.add("⚠️ Shortened URL detected — hides the real destination.");
        }

        // 9. Subdomain depth
        int subdomainDepth = countSubdomains(domain);
        if (subdomainDepth > 3) {
            score += 20;
            reasons.add("⚠️ Excessive subdomain depth (" + subdomainDepth + " levels) — common phishing pattern.");
        }

        // 10. Redirect check
        int redirectCount = estimateRedirects(url);
        if (redirectCount > 2) {
            score += 25;
            reasons.add("⚠️ Multiple redirects detected (" + redirectCount + ") — URL may hide final destination.");
        }

        // 11. Suspicious TLD
        if (hasSuspiciousTld(domain)) {
            score += 15;
            reasons.add("⚠️ Suspicious top-level domain (.xyz, .tk, .ml, .ga) often used in phishing.");
        }

        // Cap score at 100
        score = Math.min(score, 100);

        if (reasons.isEmpty()) {
            reasons.add("✅ No known threats detected. URL appears safe.");
        }

        return buildResult(score, domain, reasons, false, blacklist.isBlacklisted(), url);
    }

    private DetectionResult buildResult(int score, String domain, List<String> reasons,
                                        boolean trusted, boolean blacklisted, String url) {
        return DetectionResult.builder()
                .riskScore(score)
                .status(DetectionResult.scoreToStatus(score))
                .domainName(domain)
                .sslStatus(sslChecker.isHttps(url))
                .redirectCount(estimateRedirects(url))
                .domainAgeDays(-1) // Requires WHOIS integration (Phase 3+)
                .blacklisted(blacklisted)
                .trusted(trusted)
                .reasons(reasons)
                .build();
    }

    private String sanitizeInput(String input) {
        if (input == null) return "";
        input = input.trim();
        if (!input.startsWith("http://") && !input.startsWith("https://")) {
            input = "https://" + input;
        }
        return input;
    }

    private String extractDomain(String url) {
        if (url == null || url.contains(" ")) {
            return "N/A";
        }
        String result;
        try {
            URI uri = new URI(url);
            String host = uri.getHost();
            result = host != null ? host.toLowerCase() : url.toLowerCase();
        } catch (Exception e) {
            result = url.toLowerCase();
        }
        return result.length() > 255 ? result.substring(0, 255) : result;
    }

    private boolean isIpBasedUrl(String url) {
        return url.matches(".*://\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}.*");
    }

    private int countSubdomains(String domain) {
        if (domain == null) return 0;
        return domain.split("\\.").length - 2;
    }

    private int estimateRedirects(String url) {
        // Heuristic: shortened URLs / URLs with 'redirect' param likely have redirects
        if (shortenerDetector.isShortened(extractDomain(url))) return 3;
        if (url.contains("redirect") || url.contains("url=") || url.contains("goto=")) return 2;
        return 0;
    }

    private boolean hasSuspiciousTld(String domain) {
        String[] suspiciousTlds = {".xyz", ".tk", ".ml", ".ga", ".cf", ".gq", ".top", ".click", ".loan"};
        for (String tld : suspiciousTlds) {
            if (domain.endsWith(tld)) return true;
        }
        return false;
    }
}
