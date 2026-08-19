package com.phishguard.controller;

import com.phishguard.dto.response.ApiResponse;
import com.phishguard.exception.BadRequestException;
import com.phishguard.model.Alert;
import com.phishguard.model.ScanHistory;
import com.phishguard.model.ScamReport;
import com.phishguard.model.User;
import com.phishguard.repository.ScanHistoryRepository;
import com.phishguard.repository.ScamReportRepository;
import com.phishguard.repository.UserRepository;
import com.phishguard.service.AlertsService;
import lombok.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

@RestController
@RequestMapping("/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final UserRepository userRepository;
    private final ScanHistoryRepository scanHistoryRepository;
    private final AlertsService alertsService;
    private final ScamReportRepository scamReportRepository;

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<DashboardStats>> getStats() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("User not found."));

        long totalScans = scanHistoryRepository.countByUserId(user.getId());
        long blockedThreats = scanHistoryRepository.countBlockedThreats(user.getId());

        // Security score
        int securityScore = totalScans == 0 ? 100
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
        Map<String, double[]> coordinatesRegistry = new HashMap<>();
        coordinatesRegistry.put("DELHI", new double[]{28.70, 77.10});
        coordinatesRegistry.put("MUMBAI", new double[]{19.07, 72.87});
        coordinatesRegistry.put("JAMTARA", new double[]{24.13, 86.80});
        coordinatesRegistry.put("BENGALURU", new double[]{12.97, 77.59});
        coordinatesRegistry.put("HYDERABAD", new double[]{17.38, 78.48});
        coordinatesRegistry.put("CHENNAI", new double[]{13.08, 80.27});
        coordinatesRegistry.put("KOLKATA", new double[]{22.57, 88.36});
        coordinatesRegistry.put("PUNE", new double[]{18.52, 73.85});
        coordinatesRegistry.put("AHMEDABAD", new double[]{23.02, 72.57});

        Map<String, MapHotspot> hotspotsMap = new HashMap<>();
        hotspotsMap.put("JAMTARA", new MapHotspot("Jamtara", 24.13, 86.80, 480, "Aadhaar KYC SMS Scams", "CRITICAL"));
        hotspotsMap.put("MUMBAI", new MapHotspot("Mumbai", 19.07, 72.87, 290, "UPI Reward Scams", "HIGH"));
        hotspotsMap.put("DELHI", new MapHotspot("Delhi", 28.70, 77.10, 245, "Fake HDFC Portals", "HIGH"));
        hotspotsMap.put("BENGALURU", new MapHotspot("Bengaluru", 12.97, 77.59, 190, "Fake Courier Fees", "MEDIUM"));
        hotspotsMap.put("HYDERABAD", new MapHotspot("Hyderabad", 17.38, 78.48, 170, "Govt Scheme Subsidies", "MEDIUM"));

        try {
            List<ScamReport> reports = scamReportRepository.findAll();
            for (ScamReport report : reports) {
                String city = report.getCity();
                if (city == null || city.trim().isEmpty() || "N/A".equalsIgnoreCase(city)) {
                    continue;
                }
                String cityKey = city.trim().toUpperCase();

                double lat = report.getLatitude() != null ? report.getLatitude() : 0.0;
                double lng = report.getLongitude() != null ? report.getLongitude() : 0.0;
                if (lat == 0.0 && lng == 0.0) {
                    double[] coords = coordinatesRegistry.get(cityKey);
                    if (coords != null) {
                        lat = coords[0];
                        lng = coords[1];
                    } else {
                        lat = 20.5937;
                        lng = 78.9629;
                    }
                }

                String reportCategoryStr = report.getCategory() != null ? report.getCategory().name() : "OTHER";
                String userFriendlyScam = formatCategoryName(reportCategoryStr);

                if (hotspotsMap.containsKey(cityKey)) {
                    MapHotspot existing = hotspotsMap.get(cityKey);
                    existing.setThreatCount(existing.getThreatCount() + 1);
                    existing.setTopScam(userFriendlyScam);
                    existing.setSeverity(calculateSeverity(existing.getThreatCount()));
                } else {
                    String titleCaseCity = toTitleCase(city);
                    MapHotspot newHotspot = new MapHotspot(
                        titleCaseCity,
                        lat,
                        lng,
                        1,
                        userFriendlyScam,
                        "MEDIUM"
                    );
                    hotspotsMap.put(cityKey, newHotspot);
                }
            }
        } catch (Exception e) {
            // Fallback gracefully if database table hasn't updated/synced yet
        }

        List<MapHotspot> list = new ArrayList<>(hotspotsMap.values());
        return ResponseEntity.ok(ApiResponse.success(list, "Map hotspots retrieved."));
    }

    private String formatCategoryName(String category) {
        if (category == null) return "Unknown Scam";
        switch (category.toUpperCase()) {
            case "BANK_SCAM": return "Bank Phishing Portal";
            case "UPI_SCAM": return "UPI Reward Scam";
            case "COURIER_SCAM": return "Fake Courier Fee";
            case "GOVT_SCAM": return "Govt Scheme Impersonation";
            case "SMS_SCAM": return "SMS Phishing Scam";
            case "EMAIL_SCAM": return "Email Phishing Scam";
            default: return "Online Security Threat";
        }
    }

    private String calculateSeverity(int count) {
        if (count >= 300) return "CRITICAL";
        if (count >= 200) return "HIGH";
        if (count > 5) return "HIGH";
        if (count >= 3) return "MEDIUM";
        return "MEDIUM";
    }

    private String toTitleCase(String text) {
        if (text == null || text.isEmpty()) return text;
        StringBuilder sb = new StringBuilder();
        boolean nextTitleCase = true;
        for (char c : text.toCharArray()) {
            if (Character.isSpaceChar(c)) {
                nextTitleCase = true;
            } else if (nextTitleCase) {
                c = Character.toTitleCase(c);
                nextTitleCase = false;
            } else {
                c = Character.toLowerCase(c);
            }
            sb.append(c);
        }
        return sb.toString();
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
