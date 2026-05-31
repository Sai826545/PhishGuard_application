package com.phishguard.service;

import com.phishguard.dto.request.LoginRequest;
import com.phishguard.dto.request.SignupRequest;
import com.phishguard.dto.response.AuthResponse;
import com.phishguard.exception.BadRequestException;
import com.phishguard.model.User;
import com.phishguard.model.UserSettings;
import com.phishguard.repository.UserRepository;
import com.phishguard.repository.UserSettingsRepository;
import com.phishguard.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final UserSettingsRepository userSettingsRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthenticationManager authenticationManager;

    @Transactional
    public AuthResponse signup(SignupRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email is already registered.");
        }
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BadRequestException("Username is already taken.");
        }

        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .totalScans(0)
                .blockedThreats(0)
                .preferredLanguage("en")
                .build();
        user = userRepository.save(user);

        // Create default settings for new user
        UserSettings settings = UserSettings.builder()
                .user(user)
                .darkMode(true)
                .biometricLogin(false)
                .notificationsEnabled(true)
                .language("en")
                .build();
        userSettingsRepository.save(settings);

        String accessToken = jwtTokenProvider.generateAccessToken(user.getEmail());
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getEmail());

        return AuthResponse.of(accessToken, refreshToken, user);
    }

    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new BadRequestException("User not found."));

        String accessToken = jwtTokenProvider.generateAccessToken(user.getEmail());
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getEmail());

        return AuthResponse.of(accessToken, refreshToken, user);
    }

    public AuthResponse refreshToken(String refreshToken) {
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new BadRequestException("Invalid or expired refresh token.");
        }

        String email = jwtTokenProvider.getEmailFromToken(refreshToken);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("User not found."));

        String newAccessToken = jwtTokenProvider.generateAccessToken(email);
        String newRefreshToken = jwtTokenProvider.generateRefreshToken(email);

        return AuthResponse.of(newAccessToken, newRefreshToken, user);
    }

    // In-memory OTP cache: Email -> OtpData
    private static final java.util.concurrent.ConcurrentHashMap<String, OtpData> otpCache = 
            new java.util.concurrent.ConcurrentHashMap<>();

    private static class OtpData {
        String code;
        long expiryTime;

        OtpData(String code, long expiryTime) {
            this.code = code;
            this.expiryTime = expiryTime;
        }
    }

    public void sendPasswordResetOtp(String email) {
        if (!userRepository.existsByEmail(email)) {
            throw new BadRequestException("Email is not registered.");
        }
        String otpCode = String.format("%06d", new java.util.Random().nextInt(1000000));
        long expiryTime = System.currentTimeMillis() + (10 * 60 * 1000);
        otpCache.put(email, new OtpData(otpCode, expiryTime));

        System.out.println("==================================================");
        System.out.println("🔐 PHISHGUARD PASSWORD RESET SERVICE");
        System.out.println("Recipient Email: " + email);
        System.out.println("Your 6-digit OTP code is: " + otpCode);
        System.out.println("Expiry: 10 minutes");
        System.out.println("==================================================");
    }

    @Transactional
    public void resetPassword(String email, String otp, String newPassword) {
        OtpData otpData = otpCache.get(email);
        if (otpData == null) {
            throw new BadRequestException("No verification request found for this email.");
        }
        if (System.currentTimeMillis() > otpData.expiryTime) {
            otpCache.remove(email);
            throw new BadRequestException("Verification code has expired.");
        }
        if (!otpData.code.equals(otp)) {
            throw new BadRequestException("Invalid verification code.");
        }
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("User not found."));
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        otpCache.remove(email);
    }
}
