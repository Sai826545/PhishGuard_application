package com.phishguard.repository;

import com.phishguard.model.ScanHistory;
import com.phishguard.model.ScanHistory.ResultStatus;
import com.phishguard.model.ScanHistory.ScanType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScanHistoryRepository extends JpaRepository<ScanHistory, Long> {

    Page<ScanHistory> findByUserIdOrderByScannedAtDesc(Long userId, Pageable pageable);

    Page<ScanHistory> findByUserIdAndResultStatusOrderByScannedAtDesc(
            Long userId, ResultStatus status, Pageable pageable);

    Page<ScanHistory> findByUserIdAndScanTypeOrderByScannedAtDesc(
            Long userId, ScanType scanType, Pageable pageable);

    @Query("SELECT COUNT(sh) FROM ScanHistory sh WHERE sh.user.id = :userId")
    long countByUserId(@Param("userId") Long userId);

    @Query("SELECT COUNT(sh) FROM ScanHistory sh WHERE sh.user.id = :userId AND sh.resultStatus = 'DANGEROUS'")
    long countBlockedThreats(@Param("userId") Long userId);

    List<ScanHistory> findTop5ByUserIdOrderByScannedAtDesc(Long userId);
}
