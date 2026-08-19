package com.phishguard.dto.response;

import com.phishguard.model.ScamReport;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class PublicReportResponse {
    private Long id;
    private String reportedBy;
    private String category;
    private String content;
    private String description;
    private String screenshotUrl;
    private String city;
    private LocalDateTime reportedAt;

    public static PublicReportResponse fromEntity(ScamReport report) {
        return PublicReportResponse.builder()
                .id(report.getId())
                .reportedBy(report.getUser() != null ? report.getUser().getUsername() : "Anonymous")
                .category(report.getCategory() != null ? report.getCategory().name() : "OTHER")
                .content(report.getContent())
                .description(report.getDescription())
                .screenshotUrl(report.getScreenshotUrl())
                .city(report.getCity())
                .reportedAt(report.getReportedAt())
                .build();
    }
}
