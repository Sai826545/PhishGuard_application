package com.phishguard.engine;

import org.springframework.stereotype.Component;
import java.util.Arrays;
import java.util.List;

@Component
public class SslChecker {

    public boolean isHttps(String url) {
        if (url == null) return false;
        return url.toLowerCase().startsWith("https://");
    }
}
