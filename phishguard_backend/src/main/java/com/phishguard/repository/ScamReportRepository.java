package com.phishguard.repository;

import com.phishguard.model.ScamReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScamReportRepository extends JpaRepository<ScamReport, Long> {
    List<ScamReport> findByUserIdOrderByReportedAtDesc(Long userId);
}
