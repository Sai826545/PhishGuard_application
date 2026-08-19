package com.phishguard.controller;

import com.phishguard.dto.request.ReportRequest;
import com.phishguard.dto.response.ApiResponse;
import com.phishguard.dto.response.AuthResponse;
import com.phishguard.dto.response.PublicReportResponse;
import com.phishguard.model.ScamReport;
import com.phishguard.service.ReportService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/report")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    @PostMapping(value = "/upload", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<java.util.Map<String, String>>> uploadScreenshot(
            @RequestParam("file") org.springframework.web.multipart.MultipartFile file) {
        if (file.isEmpty()) {
            throw new com.phishguard.exception.BadRequestException("File is empty.");
        }
        try {
            String uploadDir = System.getProperty("user.dir") + java.io.File.separator + "uploads";
            java.io.File dir = new java.io.File(uploadDir);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String filename = java.util.UUID.randomUUID().toString() + extension;
            java.io.File destFile = new java.io.File(dir, filename);
            file.transferTo(destFile);

            String fileUrl = "/api/uploads/" + filename;
            java.util.Map<String, String> response = new java.util.HashMap<>();
            response.put("url", fileUrl);

            return ResponseEntity.ok(ApiResponse.success(response, "Screenshot uploaded."));
        } catch (java.io.IOException e) {
            throw new com.phishguard.exception.BadRequestException("Failed to upload file: " + e.getMessage());
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ScamReport>> submitReport(
            @Valid @RequestBody ReportRequest request) {
        ScamReport report = reportService.submitReport(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(report, "Report submitted. Thank you for helping protect others!"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ScamReport>>> getMyReports() {
        return ResponseEntity.ok(ApiResponse.success(
                reportService.getUserReports(), "Reports retrieved."));
    }

    @GetMapping("/community")
    public ResponseEntity<ApiResponse<List<PublicReportResponse>>> getCommunityReports() {
        return ResponseEntity.ok(ApiResponse.success(
                reportService.getAllPublicReports(), "Community reports feed retrieved."));
    }
}
