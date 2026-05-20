package com.phishguard.controller;

import com.phishguard.dto.response.ApiResponse;
import com.phishguard.dto.response.ScanResponse;
import com.phishguard.service.HistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/history")
@RequiredArgsConstructor
public class HistoryController {

    private final HistoryService historyService;

    @GetMapping
    public ResponseEntity<ApiResponse<Page<ScanResponse>>> getHistory(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "ALL") String filter) {
        Page<ScanResponse> history = historyService.getHistory(page, size, filter);
        return ResponseEntity.ok(ApiResponse.success(history, "History retrieved."));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<String>> deleteHistory(@PathVariable Long id) {
        historyService.deleteHistory(id);
        return ResponseEntity.ok(ApiResponse.success("Deleted", "Scan record deleted."));
    }
}
