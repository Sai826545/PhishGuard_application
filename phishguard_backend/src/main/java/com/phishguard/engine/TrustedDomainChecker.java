package com.phishguard.engine;

import com.phishguard.repository.TrustedDomainRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
@RequiredArgsConstructor
public class TrustedDomainChecker {

    private final TrustedDomainRepository trustedDomainRepository;

    private static final List<String> CORE_TRUSTED = Arrays.asList(
            "sbi.co.in", "onlinesbi.sbi", "hdfcbank.com", "icicibank.com",
            "axisbank.com", "kotak.com", "uidai.gov.in", "incometax.gov.in",
            "india.gov.in", "paytm.com", "phonepe.com", "googlepay.com",
            "amazon.in", "flipkart.com", "irctc.co.in", "razorpay.com"
    );

    public boolean isTrusted(String domain) {
        if (domain == null) return false;
        // Exact match on core list
        for (String trusted : CORE_TRUSTED) {
            if (domain.equals(trusted) || domain.endsWith("." + trusted)) {
                return true;
            }
        }
        // Database check
        return trustedDomainRepository.existsByDomain(domain);
    }
}
