package com.phishguard.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "trusted_domains")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrustedDomain {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String domain;

    @Column(name = "brand_name", length = 100)
    private String brandName;
}
