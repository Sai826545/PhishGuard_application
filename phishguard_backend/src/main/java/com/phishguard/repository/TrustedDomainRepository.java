package com.phishguard.repository;

import com.phishguard.model.TrustedDomain;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TrustedDomainRepository extends JpaRepository<TrustedDomain, Long> {
    Optional<TrustedDomain> findByDomain(String domain);
    boolean existsByDomain(String domain);
}
