package ru.youngstanis.models;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.*;

import static ru.youngstanis.constants.TableNames.CRYPTOCURRENCIES;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder(setterPrefix = "with")
@Table(name = CRYPTOCURRENCIES)
public class Cryptocurrency {

    @Id
    private Long id;

    @Column(name = "full_name")
    private String full_name;

    @Column(name = "short_name")
    private String short_name;

    @Column(name = "amount")
    private Double amount;

    @Column(name = "added_at_utc")
    private Long addedAtUtc;

    @Column(name = "buy_price_dollar")
    private Double buyPriceDollar;

    @ManyToOne
    @JoinColumn(name = "portfolio_id", nullable = false)
    @JsonManagedReference
    private Portfolio portfolio;
}

