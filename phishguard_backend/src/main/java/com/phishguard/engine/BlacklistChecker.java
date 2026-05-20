package com.phishguard.engine;

import com.phishguard.repository.BlacklistedDomainRepository;
import lombok.*;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
@RequiredArgsConstructor
public class BlacklistChecker {

    private final BlacklistedDomainRepository blacklistedDomainRepository;

    // In-memory high-priority blacklist for fast lookup
    private static final List<String> HIGH_PRIORITY_DOMAINS = Arrays.asList(
            "sbi-secure-login.com", "sbionline-kyc.com", "hdfc-netbanking-secure.com",
            "icici-bank-kyc.in", "aadhaar-update-online.in", "upi-refund-claim.com",
            "delhivery-parcel-pending.com", "indiapost-track-parcel.in"
    );

    public BlacklistResult check(String domain, String url) {
        // Check in-memory first (fast)
        for (String blocked : HIGH_PRIORITY_DOMAINS) {
            if (domain.contains(blocked) || url.contains(blocked)) {
                return new BlacklistResult(true, "HIGH_PRIORITY_PHISHING");
            }
        }

        // Check database
        return blacklistedDomainRepository.findByDomain(domain)
                .map(bd -> new BlacklistResult(true, bd.getCategory()))
                .orElseGet(() -> {
                    // Partial match check
                    for (var bd : blacklistedDomainRepository.findAll()) {
                        if (domain.contains(bd.getDomain()) || bd.getDomain().contains(domain)) {
                            return new BlacklistResult(true, bd.getCategory());
                        }
                    }
                    return new BlacklistResult(false, null);
                });
    }

    @Data
    @AllArgsConstructor
    public static class BlacklistResult {
        private boolean blacklisted;
        private String category;
    }
}
