package com.phishguard.repository;

import com.phishguard.model.BlacklistedDomain;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface BlacklistedDomainRepository extends JpaRepository<BlacklistedDomain, Long> {

    Optional<BlacklistedDomain> findByDomain(String domain);

    boolean existsByDomain(String domain);

    @Query("SELECT b FROM BlacklistedDomain b WHERE :domain LIKE CONCAT('%', b.domain, '%')")
    Optional<BlacklistedDomain> findByDomainContaining(@Param("domain") String domain);
}
