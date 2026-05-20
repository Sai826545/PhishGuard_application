package com.phishguard.repository;

import com.phishguard.model.Alert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AlertRepository extends JpaRepository<Alert, Long> {
    List<Alert> findByIsActiveTrueOrderByPublishedAtDesc();
    List<Alert> findBySeverityAndIsActiveTrue(Alert.Severity severity);
}
