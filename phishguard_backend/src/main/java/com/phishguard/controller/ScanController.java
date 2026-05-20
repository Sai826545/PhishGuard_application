package com.phishguard.controller;

import com.phishguard.dto.request.ScanRequest;
import com.phishguard.dto.response.ApiResponse;
import com.phishguard.dto.response.ScanResponse;
import com.phishguard.service.ScanService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/scan")
@RequiredArgsConstructor
public class ScanController {

    private final ScanService scanService;

    @PostMapping("/url")
    public ResponseEntity<ApiResponse<ScanResponse>> scanUrl(
            @Valid @RequestBody ScanRequest request) {
        ScanResponse response = scanService.scanUrl(request.getContent());
        return ResponseEntity.ok(ApiResponse.success(response, "URL scan completed."));
    }

    @PostMapping("/qr")
    public ResponseEntity<ApiResponse<ScanResponse>> scanQr(
            @Valid @RequestBody ScanRequest request) {
        ScanResponse response = scanService.scanQr(request.getContent());
        return ResponseEntity.ok(ApiResponse.success(response, "QR scan completed."));
    }

    @PostMapping("/sms")
    public ResponseEntity<ApiResponse<ScanResponse>> scanSms(
            @Valid @RequestBody ScanRequest request) {
        ScanResponse response = scanService.scanSms(request.getContent());
        return ResponseEntity.ok(ApiResponse.success(response, "SMS scan completed."));
    }

    @PostMapping("/email")
    public ResponseEntity<ApiResponse<ScanResponse>> scanEmail(
            @Valid @RequestBody ScanRequest request) {
        ScanResponse response = scanService.scanEmail(request.getContent());
        return ResponseEntity.ok(ApiResponse.success(response, "Email scan completed."));
    }
}
