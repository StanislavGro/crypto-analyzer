package ru.youngstanis.models;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.List;

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
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    private Long id;

    @Column(name = "full_name")
    private String fullName;

    @Column(name = "short_name")
    private String shortName;

    @Column(name = "amount")
    private Double amount;

    @Column(name = "added_at")
    private Instant addedAt;

    @Column(name = "buy_price")
    private Double buyPrice;

    @ManyToOne
    @JoinColumn(name = "portfolio_id", nullable = false)
    @JsonManagedReference
    private Portfolio portfolio;

    @OneToMany(mappedBy = "cryptocurrency")
    @JsonBackReference
    private List<Transaction> transactions;
}

