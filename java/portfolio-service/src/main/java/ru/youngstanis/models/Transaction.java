package ru.youngstanis.models;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import ru.youngstanis.constants.TableNames;
import ru.youngstanis.models.enums.OperationType;

import java.time.Instant;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = TableNames.TRANSACTIONS)
public class Transaction {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "coin_name")
    private String tokenName;

    @Column(name = "amount")
    private Double amount;

    @Column(name = "coin_price")
    private Double coinPrice;

    @Column(name = "operation_type")
    private OperationType operationType;

    @Column(name = "creation_time")
    private Instant creation_time;

    @ManyToOne
    @JoinColumn(name = "portfolio_id", nullable = false)
    @JsonBackReference
    private Portfolio portfolio;
}

