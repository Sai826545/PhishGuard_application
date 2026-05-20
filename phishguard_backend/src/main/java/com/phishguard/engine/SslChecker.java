package com.phishguard.engine;

import org.springframework.stereotype.Component;
import java.util.Arrays;
import java.util.List;

@Component
public class SslChecker {

    private static final List<String> SHORTENER_DOMAINS = Arrays.asList(
            "bit.ly", "tinyurl.com", "t.co", "goo.gl", "ow.ly",
            "short.io", "rebrand.ly", "cutt.ly", "tiny.cc",
            "is.gd", "buff.ly", "adf.ly", "shorte.st"
    );

    public boolean isHttps(String url) {
        if (url == null) return false;
        return url.toLowerCase().startsWith("https://");
    }
}
