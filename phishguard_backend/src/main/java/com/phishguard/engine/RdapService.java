package com.phishguard.engine;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

@Service
@Slf4j
public class RdapService {

    private final RestTemplate restTemplate = new RestTemplate();
    private static final String RDAP_URL = "https://rdap.org/domain/";

    public int getDomainAgeDays(String domain) {
        if (domain == null || domain.trim().isEmpty() || "N/A".equalsIgnoreCase(domain)) {
            return -1;
        }

        try {
            String url = RDAP_URL + domain.trim().toLowerCase();
            log.info("Querying RDAP for domain: {}", domain);
            
            // RestTemplate automatically follows redirects (302) to authoritative registries
            JsonNode response = restTemplate.getForObject(url, JsonNode.class);
            if (response == null) {
                return -1;
            }

            JsonNode events = response.get("events");
            if (events != null && events.isArray()) {
                for (JsonNode event : events) {
                    JsonNode action = event.get("eventAction");
                    JsonNode dateNode = event.get("eventDate");
                    
                    if (action != null && dateNode != null) {
                        String actionStr = action.asText();
                        // Look for registration or creation event
                        if ("registration".equalsIgnoreCase(actionStr) || "registration date".equalsIgnoreCase(actionStr) || "creation".equalsIgnoreCase(actionStr)) {
                            String dateStr = dateNode.asText();
                            Instant creationInstant = Instant.parse(dateStr);
                            Instant now = Instant.now();
                            long days = ChronoUnit.DAYS.between(creationInstant, now);
                            log.info("RDAP success: domain {} created on {}, age in days: {}", domain, dateStr, days);
                            return (int) days;
                        }
                    }
                }
            }
        } catch (Exception e) {
            log.warn("Failed to retrieve RDAP whois data for domain {}: {}", domain, e.getMessage());
        }
        return -1;
    }
}
