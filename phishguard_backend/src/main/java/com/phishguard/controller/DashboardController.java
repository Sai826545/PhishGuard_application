package com.phishguard.controller;

import com.phishguard.dto.response.ApiResponse;
import com.phishguard.exception.BadRequestException;
import com.phishguard.model.Alert;
import com.phishguard.model.ScanHistory;
import com.phishguard.model.User;
import com.phishguard.repository.ScanHistoryRepository;
import com.phishguard.repository.UserRepository;
import com.phishguard.service.AlertsService;
import lombok.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final UserRepository userRepository;
    private final ScanHistoryRepository scanHistoryRepository;
    private final AlertsService alertsService;

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<DashboardStats>> getStats() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("User not found."));

        long totalScans = scanHistoryRepository.countByUserId(user.getId());
        long blockedThreats = scanHistoryRepository.countBlockedThreats(user.getId());

        // Security score
        int securityScore = totalScans == 0 ? 75
                : (int) Math.min(100, (1.0 - (double) blockedThreats / totalScans) * 100);

        // Recent scans
        List<ScanHistory> recent = scanHistoryRepository.findTop5ByUserIdOrderByScannedAtDesc(user.getId());

        // Latest critical alerts from dynamic feed
        List<Alert> latestAlerts = alertsService.getAlertsBySeverity("CRITICAL");
        if (latestAlerts.isEmpty()) {
            latestAlerts = alertsService.getAllAlerts();
        }

        // Cybersecurity tips rotation
        String[] tips = {
                "💡 Never share your OTP with anyone, even if they claim to be from your bank.",
                "💡 Always check the website URL before entering banking credentials.",
                "💡 Enable two-factor authentication (2FA) on all your important accounts.",
                "💡 Be suspicious of urgent messages asking you to 'act immediately'.",
                "💡 Government agencies like UIDAI and Income Tax never ask for OTPs via SMS.",
                "💡 Verify QR codes before scanning them in public places.",
                "💡 Update your apps regularly to patch security vulnerabilities.",
                "💡 Use strong, unique passwords for each account."
        };
        int tipIndex = (int) (System.currentTimeMillis() / 3600000) % tips.length;

        DashboardStats stats = DashboardStats.builder()
                .username(user.getUsername())
                .securityScore(securityScore)
                .totalScans((int) totalScans)
                .blockedThreats((int) blockedThreats)
                .recentScans(recent)
                .latestAlerts(latestAlerts.subList(0, Math.min(3, latestAlerts.size())))
                .dailyCybertip(tips[tipIndex])
                .build();

        return ResponseEntity.ok(ApiResponse.success(stats, "Dashboard stats retrieved."));
    }

    @GetMapping("/map-hotspots")
    public ResponseEntity<ApiResponse<List<MapHotspot>>> getMapHotspots() {
        List<MapHotspot> hotspots = List.of(
            new MapHotspot("Jamtara", 24.13, 86.80, 480, "Aadhaar KYC SMS Scams", "CRITICAL"),
            new MapHotspot("Mumbai", 19.07, 72.87, 290, "UPI Reward Scams", "HIGH"),
            new MapHotspot("Delhi", 28.70, 77.10, 245, "Fake HDFC Portals", "HIGH"),
            new MapHotspot("Bengaluru", 12.97, 77.59, 190, "Fake Courier Fees", "MEDIUM"),
            new MapHotspot("Hyderabad", 17.38, 78.48, 170, "Govt Scheme Subsidies", "MEDIUM")
        );
        return ResponseEntity.ok(ApiResponse.success(hotspots, "Map hotspots retrieved."));
    }

    @Data
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static class MapHotspot {
        private String city;
        private double lat;
        private double lng;
        private int threatCount;
        private String topScam;
        private String severity;
    }

    @Data
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static class DashboardStats {
        private String username;
        private int securityScore;
        private int totalScans;
        private int blockedThreats;
        private List<ScanHistory> recentScans;
        private List<Alert> latestAlerts;
        private String dailyCybertip;
    }
}
