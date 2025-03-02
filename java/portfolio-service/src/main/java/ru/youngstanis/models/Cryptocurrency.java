package ru.youngstanis.models;

import jakarta.persistence.*;
import lombok.*;
import ru.youngstanis.constants.TableNames;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder(setterPrefix = "with")
@Table(name = TableNames.CRYPTOCURRENCY)
public class Cryptocurrency {

    @Id
    private Long id;

    @Column(name = "name")
    private String name;

    @Column(name = "amount")
    private Long amount;

    @Column(name = "added_at")
    private Long addedAt;

    @Column(name = "buy_price_dollar")
    private Long buyPriceDollar;

    @ManyToOne
    @JoinColumn(name = "portfolio_id", nullable = false)
    private Portfolio portfolio;
}

