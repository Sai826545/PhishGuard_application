package com.phishguard.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "user_settings")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSettings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "dark_mode")
    @Builder.Default
    private Boolean darkMode = true;

    @Column(name = "biometric_login")
    @Builder.Default
    private Boolean biometricLogin = false;

    @Column(name = "notifications_enabled")
    @Builder.Default
    private Boolean notificationsEnabled = true;

    @Column(length = 10)
    @Builder.Default
    private String language = "en";

    @Column(name = "auto_scan_sms")
    @Builder.Default
    private Boolean autoScanSms = false;

    @Column(name = "share_anonymous_data")
    @Builder.Default
    private Boolean shareAnonymousData = true;
}
