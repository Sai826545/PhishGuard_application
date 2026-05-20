package com.phishguard.service;

import com.phishguard.model.Alert;
import com.phishguard.repository.AlertRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AlertsService {

    private final AlertRepository alertRepository;

    public List<Alert> getAllAlerts() {
        return alertRepository.findByIsActiveTrueOrderByPublishedAtDesc();
    }

    public List<Alert> getAlertsBySeverity(String severity) {
        try {
            Alert.Severity sev = Alert.Severity.valueOf(severity.toUpperCase());
            return alertRepository.findBySeverityAndIsActiveTrue(sev);
        } catch (IllegalArgumentException e) {
            return getAllAlerts();
        }
    }
}
