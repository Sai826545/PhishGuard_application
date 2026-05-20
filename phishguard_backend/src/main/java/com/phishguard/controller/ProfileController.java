package com.phishguard.controller;

import com.phishguard.dto.response.ApiResponse;
import com.phishguard.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping
    public ResponseEntity<ApiResponse<ProfileService.ProfileResponse>> getProfile() {
        return ResponseEntity.ok(ApiResponse.success(profileService.getProfile(), "Profile retrieved."));
    }
}
