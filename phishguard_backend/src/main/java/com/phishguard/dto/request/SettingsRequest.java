package com.phishguard.dto.request;

import lombok.Data;

@Data
public class SettingsRequest {
    private Boolean darkMode;
    private Boolean biometricLogin;
    private Boolean notificationsEnabled;
    private String language;
    private Boolean autoScanSms;
    private Boolean shareAnonymousData;
}
