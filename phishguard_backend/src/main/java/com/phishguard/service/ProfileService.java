package com.phishguard.service;

import com.phishguard.dto.response.ScanResponse;
import com.phishguard.exception.BadRequestException;
import com.phishguard.model.ScanHistory;
import com.phishguard.model.User;
import com.phishguard.repository.ScanHistoryRepository;
import com.phishguard.repository.UserRepository;
import lombok.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final UserRepository userRepository;
    private final ScanHistoryRepository scanHistoryRepository;

    public ProfileResponse getProfile() {
        User user = getCurrentUser();
        long totalScans = scanHistoryRepository.countByUserId(user.getId());
        long blockedThreats = scanHistoryRepository.countBlockedThreats(user.getId());

        // Compute achievements
        List<String> badges = computeBadges(totalScans, blockedThreats);

        return ProfileResponse.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .totalScans((int) totalScans)
                .blockedThreats((int) blockedThreats)
                .preferredLanguage(user.getPreferredLanguage())
                .joinedDate(user.getCreatedAt())
                .achievementBadges(badges)
                .securityScore(computeSecurityScore(totalScans, blockedThreats))
                .build();
    }

    private List<String> computeBadges(long scans, long threats) {
        List<String> badges = new java.util.ArrayList<>();
        if (scans >= 1) badges.add("🛡️ First Scan");
        if (scans >= 10) badges.add("🔍 10 Scans Done");
        if (scans >= 50) badges.add("🏅 50 Scans Done");
        if (scans >= 100) badges.add("🏆 100 Scans Champion");
        if (scans >= 500) badges.add("⭐ 500 Scans Legend");
        if (threats >= 1) badges.add("🦺 First Threat Blocked");
        if (threats >= 10) badges.add("💪 10 Threats Blocked");
        if (threats >= 50) badges.add("🔰 Cyber Guardian");
        return badges;
    }

    private int computeSecurityScore(long scans, long threats) {
        if (scans == 0) return 100;
        double safeRatio = 1.0 - ((double) threats / scans);
        return (int) Math.min(100, Math.max(0, safeRatio * 100));
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("User not found."));
    }

    @Data
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static class ProfileResponse {
        private Long userId;
        private String username;
        private String email;
        private int totalScans;
        private int blockedThreats;
        private String preferredLanguage;
        private LocalDateTime joinedDate;
        private List<String> achievementBadges;
        private int securityScore;
    }
}
