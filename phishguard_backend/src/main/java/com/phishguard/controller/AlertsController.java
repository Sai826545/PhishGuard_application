package com.phishguard.controller;

import com.phishguard.dto.response.ApiResponse;
import com.phishguard.model.Alert;
import com.phishguard.service.AlertsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/alerts")
@RequiredArgsConstructor
public class AlertsController {

    private final AlertsService alertsService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<Alert>>> getAlerts(
            @RequestParam(required = false) String severity) {
        List<Alert> alerts = (severity != null && !severity.isEmpty())
                ? alertsService.getAlertsBySeverity(severity)
                : alertsService.getAllAlerts();
        return ResponseEntity.ok(ApiResponse.success(alerts, "Alerts retrieved."));
    }
}
