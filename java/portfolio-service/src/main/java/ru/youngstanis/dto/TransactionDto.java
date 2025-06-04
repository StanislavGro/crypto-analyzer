package ru.youngstanis.dto;

import lombok.Getter;
import lombok.Setter;
import ru.youngstanis.enums.TransactionType;
import ru.youngstanis.models.Cryptocurrency;

import java.time.Instant;

@Getter
@Setter
public class TransactionDto {
    private String cryptocurrencyName;
    private Double cryptocurrencyAmount;
    private Double cryptocurrencyPrice;
    private TransactionType transactionType;
    private Instant transactionCreatedAt;
    private Cryptocurrency cryptocurrency;
}
