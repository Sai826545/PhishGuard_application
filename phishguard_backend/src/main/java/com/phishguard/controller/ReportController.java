package com.phishguard.controller;

import com.phishguard.dto.request.ReportRequest;
import com.phishguard.dto.response.ApiResponse;
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
}
