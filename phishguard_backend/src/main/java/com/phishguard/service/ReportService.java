package com.phishguard.service;

import com.phishguard.dto.request.ReportRequest;
import com.phishguard.exception.BadRequestException;
import com.phishguard.model.ScamReport;
import com.phishguard.model.User;
import com.phishguard.repository.ScamReportRepository;
import com.phishguard.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final ScamReportRepository scamReportRepository;
    private final UserRepository userRepository;

    @Transactional
    public ScamReport submitReport(ReportRequest request) {
        User user = getCurrentUser();

        ScamReport report = ScamReport.builder()
                .user(user)
                .category(ScamReport.Category.valueOf(request.getCategory().toUpperCase()))
                .content(request.getContent())
                .phoneNumber(request.getPhoneNumber())
                .description(request.getDescription())
                .screenshotUrl(request.getScreenshotUrl())
                .status(ScamReport.Status.PENDING)
                .build();

        return scamReportRepository.save(report);
    }

    public List<ScamReport> getUserReports() {
        User user = getCurrentUser();
        return scamReportRepository.findByUserIdOrderByReportedAtDesc(user.getId());
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("User not found."));
    }
}
