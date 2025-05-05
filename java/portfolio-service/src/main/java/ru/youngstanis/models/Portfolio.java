package ru.youngstanis.models;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;
import java.util.UUID;

import static ru.youngstanis.constants.TableNames.PORTFOLIO;

@Entity
@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder(setterPrefix = "with")
@Table(name = PORTFOLIO)
public class Portfolio {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    private Long id;

    @Column(name = "portfolio_name")
    private String portfolioName;

    @Column(name = "user_id")
    private UUID userId;

    @OneToMany(mappedBy = "portfolio")
    private List<Cryptocurrency> cryptocurrencies;
}
