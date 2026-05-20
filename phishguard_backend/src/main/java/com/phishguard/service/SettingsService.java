package com.phishguard.service;

import com.phishguard.dto.request.SettingsRequest;
import com.phishguard.exception.BadRequestException;
import com.phishguard.model.User;
import com.phishguard.model.UserSettings;
import com.phishguard.repository.UserRepository;
import com.phishguard.repository.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class SettingsService {

    private final UserSettingsRepository userSettingsRepository;
    private final UserRepository userRepository;

    public UserSettings getSettings() {
        User user = getCurrentUser();
        return userSettingsRepository.findByUserId(user.getId())
                .orElseGet(() -> {
                    UserSettings defaults = UserSettings.builder().user(user).build();
                    return userSettingsRepository.save(defaults);
                });
    }

    @Transactional
    public UserSettings updateSettings(SettingsRequest request) {
        User user = getCurrentUser();
        UserSettings settings = userSettingsRepository.findByUserId(user.getId())
                .orElseGet(() -> UserSettings.builder().user(user).build());

        if (request.getDarkMode() != null) settings.setDarkMode(request.getDarkMode());
        if (request.getBiometricLogin() != null) settings.setBiometricLogin(request.getBiometricLogin());
        if (request.getNotificationsEnabled() != null) settings.setNotificationsEnabled(request.getNotificationsEnabled());
        if (request.getAutoScanSms() != null) settings.setAutoScanSms(request.getAutoScanSms());
        if (request.getShareAnonymousData() != null) settings.setShareAnonymousData(request.getShareAnonymousData());

        if (request.getLanguage() != null && !request.getLanguage().isEmpty()) {
            settings.setLanguage(request.getLanguage());
            // Also update user preferred language
            user.setPreferredLanguage(request.getLanguage());
            userRepository.save(user);
        }

        return userSettingsRepository.save(settings);
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("User not found."));
    }
}
