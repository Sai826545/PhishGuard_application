package com.phishguard.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.phishguard.dto.response.ScanResponse;
import com.phishguard.engine.DetectionEngine;
import com.phishguard.engine.DetectionResult;
import com.phishguard.exception.BadRequestException;
import com.phishguard.model.ScanHistory;
import com.phishguard.model.User;
import com.phishguard.repository.ScanHistoryRepository;
import com.phishguard.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScanService {

    private final DetectionEngine detectionEngine;
    private final ScanHistoryRepository scanHistoryRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;

    private static final Pattern URL_PATTERN = Pattern.compile(
            "https?://[\\w\\-._~:/?#\\[\\]@!$&'()*+,;=%]+", Pattern.CASE_INSENSITIVE);

    @Transactional
    public ScanResponse scanUrl(String content) {
        User user = getCurrentUser();
        DetectionResult result = detectionEngine.analyze(content);
        return persistAndBuild(user, content, ScanHistory.ScanType.URL, result);
    }

    @Transactional
    public ScanResponse scanQr(String content) {
        User user = getCurrentUser();
        // QR content might be a URL, UPI ID, or plain text
        DetectionResult result = detectionEngine.analyze(content);
        return persistAndBuild(user, content, ScanHistory.ScanType.QR, result);
    }

    @Transactional
    public ScanResponse scanSms(String content) {
        User user = getCurrentUser();
        // Extract URLs from SMS content and analyze each
        List<String> urls = extractUrls(content);
        DetectionResult worst = null;

        if (!urls.isEmpty()) {
            for (String url : urls) {
                DetectionResult r = detectionEngine.analyze(url);
                if (worst == null || r.getRiskScore() > worst.getRiskScore()) {
                    worst = r;
                }
            }
        } else {
            // No URLs — just analyze keywords in the SMS text
            worst = detectionEngine.analyze(content);
        }

        return persistAndBuild(user, content, ScanHistory.ScanType.SMS, worst);
    }

    @Transactional
    public ScanResponse scanEmail(String content) {
        User user = getCurrentUser();
        List<String> urls = extractUrls(content);
        DetectionResult worst = null;

        if (!urls.isEmpty()) {
            for (String url : urls) {
                DetectionResult r = detectionEngine.analyze(url);
                if (worst == null || r.getRiskScore() > worst.getRiskScore()) {
                    worst = r;
                }
            }
        } else {
            worst = detectionEngine.analyze(content);
        }

        return persistAndBuild(user, content, ScanHistory.ScanType.EMAIL, worst);
    }

    private ScanResponse persistAndBuild(User user, String content,
                                          ScanHistory.ScanType type, DetectionResult result) {
        // Update user stats
        user.setTotalScans(user.getTotalScans() + 1);
        if ("DANGEROUS".equals(result.getStatus())) {
            user.setBlockedThreats(user.getBlockedThreats() + 1);
        }
        userRepository.save(user);

        // Persist scan history
        String reasonsJson = toJson(result.getReasons());
        ScanHistory history = ScanHistory.builder()
                .user(user)
                .scanType(type)
                .scannedContent(content.length() > 500 ? content.substring(0, 500) : content)
                .resultStatus(ScanHistory.ResultStatus.valueOf(result.getStatus()))
                .riskScore(result.getRiskScore())
                .domainName(result.getDomainName())
                .sslStatus(result.isSslStatus())
                .redirectCount(result.getRedirectCount())
                .domainAgeDays(result.getDomainAgeDays())
                .aiReasons(reasonsJson)
                .build();
        history = scanHistoryRepository.save(history);

        return ScanResponse.builder()
                .historyId(history.getId())
                .scanType(type.name())
                .scannedContent(content)
                .resultStatus(result.getStatus())
                .riskScore(result.getRiskScore())
                .domainName(result.getDomainName())
                .sslStatus(result.isSslStatus())
                .redirectCount(result.getRedirectCount())
                .domainAgeDays(result.getDomainAgeDays())
                .blacklisted(result.isBlacklisted())
                .trusted(result.isTrusted())
                .aiReasons(result.getReasons())
                .scannedAt(history.getScannedAt())
                .build();
    }

    private List<String> extractUrls(String text) {
        List<String> urls = new ArrayList<>();
        Matcher matcher = URL_PATTERN.matcher(text);
        while (matcher.find()) {
            urls.add(matcher.group());
        }
        return urls;
    }

    private String toJson(List<String> reasons) {
        try {
            return objectMapper.writeValueAsString(reasons);
        } catch (JsonProcessingException e) {
            return "[]";
        }
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("User not found."));
    }
}
