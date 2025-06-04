package ru.youngstanis.models;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;
import ru.youngstanis.constants.TableNames;
import ru.youngstanis.enums.TransactionType;

import java.time.Instant;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder(setterPrefix = "with")
@Table(name = TableNames.TRANSACTIONS)
public class Transaction {
    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "cryptocurrency_name")
    private String cryptocurrencyName;

    @Column(name = "cryptocurrency_amount")
    private Double cryptocurrencyAmount;

    @Column(name = "cryptocurrency_price")
    private Double cryptocurrencyPrice;

    @Column(name = "transaction_type")
    private TransactionType transactionType;

    @Column(name = "transaction_created_at")
    private Instant transactionCreatedAt;

    @ManyToOne
    @JoinColumn(name = "cryptocurrency_id", nullable = false)
    @JsonBackReference
    private Cryptocurrency cryptocurrency;
}

