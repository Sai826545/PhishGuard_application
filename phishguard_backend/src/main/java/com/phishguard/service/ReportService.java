package com.phishguard.service;

import com.phishguard.dto.request.ReportRequest;
import com.phishguard.dto.response.PublicReportResponse;
import com.phishguard.exception.BadRequestException;
import com.phishguard.model.ScamReport;
import com.phishguard.model.User;
import com.phishguard.repository.ScamReportRepository;
import com.phishguard.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.stream.Collectors;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final ScamReportRepository scamReportRepository;
    private final UserRepository userRepository;

    @Transactional
    public ScamReport submitReport(ReportRequest request) {
        User user = getCurrentUser();

        ScamReport.Category category;
        try {
            if (request.getCategory() == null) {
                throw new BadRequestException("Scam category is required.");
            }
            category = ScamReport.Category.valueOf(request.getCategory().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new BadRequestException("Invalid scam category: " + request.getCategory() + 
                ". Allowed categories are: BANK_SCAM, UPI_SCAM, COURIER_SCAM, GOVT_SCAM, SMS_SCAM, EMAIL_SCAM, OTHER");
        }

        ScamReport report = ScamReport.builder()
                .user(user)
                .category(category)
                .content(request.getContent())
                .phoneNumber(request.getPhoneNumber())
                .description(request.getDescription())
                .screenshotUrl(request.getScreenshotUrl())
                .city(request.getCity())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .status(ScamReport.Status.PENDING)
                .build();

        return scamReportRepository.save(report);
    }

    public List<PublicReportResponse> getAllPublicReports() {
        return scamReportRepository.findAllByOrderByReportedAtDesc().stream()
                .map(PublicReportResponse::fromEntity)
                .collect(Collectors.toList());
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
