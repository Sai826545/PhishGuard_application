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

    public static AuthResponse of(String accessToken, String refreshToken,
                                   com.phishguard.model.User user) {
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
                .build();
    }
}
