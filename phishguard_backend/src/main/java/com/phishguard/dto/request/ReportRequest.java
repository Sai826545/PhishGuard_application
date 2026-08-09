package com.phishguard.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ReportRequest {

    @NotBlank(message = "Category is required")
    private String category; // BANK_SCAM, UPI_SCAM, COURIER_SCAM, GOVT_SCAM, SMS_SCAM, EMAIL_SCAM, OTHER

    private String content;        // URL or QR content
    private String phoneNumber;    // Scam phone number
    private String description;    // Description of the scam
    private String screenshotUrl;  // Screenshot URL (uploaded separately)
    private String city;
    private Double latitude;
    private Double longitude;
}
