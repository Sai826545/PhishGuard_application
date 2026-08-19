package com.phishguard.dto.response;

import lombok.*;

@Data
@AllArgsConstructor
@Builder
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private Long userId;
    private String username;
    private String email;
    private String preferredLanguage;
    private Integer totalScans;
    private Integer blockedThreats;
    private Integer securityScore;

    public static AuthResponse of(String accessToken, String refreshToken,
                                   com.phishguard.model.User user) {
        int scans = user.getTotalScans() != null ? user.getTotalScans() : 0;
        int threats = user.getBlockedThreats() != null ? user.getBlockedThreats() : 0;
        int securityScore = scans == 0 ? 100 : (int) Math.min(100, (1.0 - (double) threats / scans) * 100);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .preferredLanguage(user.getPreferredLanguage())
                .totalScans(user.getTotalScans())
                .blockedThreats(user.getBlockedThreats())
                .securityScore(securityScore)
                .build();
    }
}
