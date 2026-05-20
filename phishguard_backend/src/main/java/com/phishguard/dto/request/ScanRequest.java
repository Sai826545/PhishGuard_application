package com.phishguard.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ScanRequest {

    @NotBlank(message = "Content to scan is required")
    private String content;

    private String scanType; // URL, QR, SMS, EMAIL (optional, auto-detected)
}
