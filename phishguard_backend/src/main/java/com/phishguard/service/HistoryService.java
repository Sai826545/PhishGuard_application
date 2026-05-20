package com.phishguard.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.phishguard.dto.response.ScanResponse;
import com.phishguard.exception.BadRequestException;
import com.phishguard.exception.ResourceNotFoundException;
import com.phishguard.model.ScanHistory;
import com.phishguard.model.User;
import com.phishguard.repository.ScanHistoryRepository;
import com.phishguard.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class HistoryService {

    private final ScanHistoryRepository scanHistoryRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;

    public Page<ScanResponse> getHistory(int page, int size, String filter) {
        User user = getCurrentUser();
        Pageable pageable = PageRequest.of(page, size);

        Page<ScanHistory> historyPage;
        if ("ALL".equalsIgnoreCase(filter) || filter == null || filter.isEmpty()) {
            historyPage = scanHistoryRepository.findByUserIdOrderByScannedAtDesc(user.getId(), pageable);
        } else {
            try {
                ScanHistory.ResultStatus status = ScanHistory.ResultStatus.valueOf(filter.toUpperCase());
                historyPage = scanHistoryRepository.findByUserIdAndResultStatusOrderByScannedAtDesc(
                        user.getId(), status, pageable);
            } catch (IllegalArgumentException e) {
                historyPage = scanHistoryRepository.findByUserIdOrderByScannedAtDesc(user.getId(), pageable);
            }
        }

        return historyPage.map(this::toScanResponse);
    }

    @Transactional
    public void deleteHistory(Long historyId) {
        User user = getCurrentUser();
        ScanHistory history = scanHistoryRepository.findById(historyId)
                .orElseThrow(() -> new ResourceNotFoundException("Scan record not found."));

        if (!history.getUser().getId().equals(user.getId())) {
            throw new BadRequestException("You can only delete your own scan records.");
        }
        scanHistoryRepository.delete(history);
    }

    private ScanResponse toScanResponse(ScanHistory history) {
        List<String> reasons = parseReasons(history.getAiReasons());
        return ScanResponse.builder()
                .historyId(history.getId())
                .scanType(history.getScanType().name())
                .scannedContent(history.getScannedContent())
                .resultStatus(history.getResultStatus().name())
                .riskScore(history.getRiskScore() != null ? history.getRiskScore() : 0)
                .domainName(history.getDomainName())
                .sslStatus(history.getSslStatus() != null && history.getSslStatus())
                .redirectCount(history.getRedirectCount() != null ? history.getRedirectCount() : 0)
                .domainAgeDays(history.getDomainAgeDays() != null ? history.getDomainAgeDays() : -1)
                .aiReasons(reasons)
                .scannedAt(history.getScannedAt())
                .build();
    }

    private List<String> parseReasons(String json) {
        if (json == null || json.isEmpty()) return List.of();
        try {
            return objectMapper.readValue(json, new TypeReference<>() {});
        } catch (Exception e) {
            return List.of();
        }
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("User not found."));
    }
}
