package com.phishguard.controller;

import com.phishguard.dto.request.SettingsRequest;
import com.phishguard.dto.response.ApiResponse;
import com.phishguard.model.UserSettings;
import com.phishguard.service.SettingsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/settings")
@RequiredArgsConstructor
public class SettingsController {

    private final SettingsService settingsService;

    @GetMapping
    public ResponseEntity<ApiResponse<UserSettings>> getSettings() {
        return ResponseEntity.ok(ApiResponse.success(settingsService.getSettings(), "Settings retrieved."));
    }

    @PutMapping("/update")
    public ResponseEntity<ApiResponse<UserSettings>> updateSettings(
            @RequestBody SettingsRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                settingsService.updateSettings(request), "Settings updated."));
    }
}
