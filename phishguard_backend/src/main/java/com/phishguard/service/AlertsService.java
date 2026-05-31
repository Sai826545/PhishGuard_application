package com.phishguard.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.phishguard.model.Alert;
import com.phishguard.repository.AlertRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class AlertsService {

    private final AlertRepository alertRepository;
    private final RestTemplate restTemplate = new RestTemplate();
    
    // Free, public RSS-to-JSON API querying the BleepingComputer Cyber Threat Feed (WAF-friendly)
    private static final String THREATS_API = 
            "https://api.rss2json.com/v1/api.json?rss_url=https://www.bleepingcomputer.com/feed/";

    public List<Alert> getAllAlerts() {
        try {
            log.info("Fetching dynamic cyber threat alerts from BleepingComputer RSS Feed...");
            JsonNode response = restTemplate.getForObject(THREATS_API, JsonNode.class);
            
            if (response != null && "ok".equalsIgnoreCase(response.get("status").asText())) {
                JsonNode items = response.get("items");
                if (items != null && items.isArray() && !items.isEmpty()) {
                    List<Alert> liveAlerts = new ArrayList<>();
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                    
                    for (JsonNode item : items) {
                        String title = item.get("title") != null ? item.get("title").asText() : "Cyber Threat Alert";
                        String rawDesc = item.get("description") != null ? item.get("description").asText() : "";
                        String description = cleanHtml(rawDesc);
                        
                        // Parse publish date
                        LocalDateTime pubDate = LocalDateTime.now();
                        if (item.get("pubDate") != null) {
                            try {
                                pubDate = LocalDateTime.parse(item.get("pubDate").asText(), formatter);
                            } catch (Exception dateEx) {
                                // Fallback to current time
                            }
                        }

                        // Determine severity based on keywords
                        Alert.Severity severity = Alert.Severity.HIGH;
                        String searchContext = (title + " " + description).toLowerCase();
                        if (searchContext.contains("urgent") || searchContext.contains("critical") || 
                            searchContext.contains("exploit") || searchContext.contains("malware") || 
                            searchContext.contains("ransomware") || searchContext.contains("breach")) {
                            severity = Alert.Severity.CRITICAL;
                        } else if (searchContext.contains("caution") || searchContext.contains("warning") || 
                                   searchContext.contains("flaw") || searchContext.contains("vulnerability")) {
                            severity = Alert.Severity.MEDIUM;
                        } else if (searchContext.contains("low") || searchContext.contains("minor")) {
                            severity = Alert.Severity.LOW;
                        }

                        // Map categories dynamically for premium UI icons
                        String category = "SCAM_ALERT";
                        if (searchContext.contains("phish") || searchContext.contains("fake") || searchContext.contains("impersonat")) {
                            category = "PHISHING";
                        } else if (searchContext.contains("bank") || searchContext.contains("card") || 
                                   searchContext.contains("payment") || searchContext.contains("refund")) {
                            category = "BANKING";
                        } else if (searchContext.contains("breach") || searchContext.contains("data") || 
                                   searchContext.contains("expose") || searchContext.contains("leak")) {
                            category = "KYC";
                        } else if (searchContext.contains("sms") || searchContext.contains("whatsapp") || searchContext.contains("text")) {
                            category = "SMS_SCAM";
                        } else if (searchContext.contains("delivery") || searchContext.contains("courier") || searchContext.contains("shipping")) {
                            category = "COURIER";
                        } else if (searchContext.contains("scheme") || searchContext.contains("subsidy") || searchContext.contains("government")) {
                            category = "GOVT_SCHEME";
                        }

                        Alert alert = Alert.builder()
                                .title(title)
                                .description(description)
                                .severity(severity)
                                .category(category)
                                .isActive(true)
                                .publishedAt(pubDate)
                                .build();
                                
                        liveAlerts.add(alert);
                    }
                    log.info("Successfully fetched {} live threat alerts from BleepingComputer.", liveAlerts.size());
                    return liveAlerts;
                }
            }
        } catch (Exception e) {
            log.warn("Failed to fetch live threat alerts API: {}. Falling back to seeded local database alerts.", e.getMessage());
        }

        // Fallback: Fetch seeded alerts from MySQL database
        return alertRepository.findByIsActiveTrueOrderByPublishedAtDesc();
    }

    public List<Alert> getAlertsBySeverity(String severity) {
        try {
            Alert.Severity sev = Alert.Severity.valueOf(severity.toUpperCase());
            // Filter live alerts list by severity
            return getAllAlerts().stream()
                    .filter(alert -> alert.getSeverity() == sev)
                    .toList();
        } catch (IllegalArgumentException e) {
            return getAllAlerts();
        }
    }

    private String cleanHtml(String html) {
        if (html == null) return "";
        // Strip HTML tags and entities
        String clean = html.replaceAll("<[^>]*>", "")
                           .replaceAll("&nbsp;", " ")
                           .replaceAll("&amp;", "&")
                           .replaceAll("&quot;", "\"")
                           .replaceAll("&apos;", "'")
                           .replaceAll("&#039;", "'")
                           .trim();
        // Truncate to avoid massive description texts
        if (clean.length() > 500) {
            clean = clean.substring(0, 500) + "...";
        }
        return clean;
    }
}
