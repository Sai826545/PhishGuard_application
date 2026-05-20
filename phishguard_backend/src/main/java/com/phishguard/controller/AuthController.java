package com.phishguard.controller;

import com.phishguard.dto.request.LoginRequest;
import com.phishguard.dto.request.RefreshTokenRequest;
import com.phishguard.dto.request.SignupRequest;
import com.phishguard.dto.response.ApiResponse;
import com.phishguard.dto.response.AuthResponse;
import com.phishguard.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/signup")
    public ResponseEntity<ApiResponse<AuthResponse>> signup(
            @Valid @RequestBody SignupRequest request) {
        AuthResponse response = authService.signup(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Account created successfully!"));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success(response, "Login successful!"));
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(
            @Valid @RequestBody RefreshTokenRequest request) {
        AuthResponse response = authService.refreshToken(request.getRefreshToken());
        return ResponseEntity.ok(ApiResponse.success(response, "Token refreshed."));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<String>> forgotPassword(
            @RequestParam String email) {
        // TODO: Implement email OTP in Phase 3+
        return ResponseEntity.ok(
                ApiResponse.success("OTP sent", "If this email is registered, an OTP will be sent."));
    }
}
