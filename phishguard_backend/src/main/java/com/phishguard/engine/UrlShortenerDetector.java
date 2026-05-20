package com.phishguard.engine;

import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
public class UrlShortenerDetector {

    private static final List<String> SHORTENER_DOMAINS = Arrays.asList(
            "bit.ly", "tinyurl.com", "t.co", "goo.gl", "ow.ly",
            "short.io", "rebrand.ly", "cutt.ly", "tiny.cc",
            "is.gd", "buff.ly", "adf.ly", "shorte.st", "v.gd",
            "bc.vc", "lnkd.in", "rb.gy", "shorturl.at", "snip.ly"
    );

    public boolean isShortened(String domain) {
        if (domain == null) return false;
        return SHORTENER_DOMAINS.stream()
                .anyMatch(s -> domain.equals(s) || domain.endsWith("." + s));
    }
}
