package ru.youngstanis.dto;

import lombok.Getter;
import lombok.Setter;
import ru.youngstanis.models.Portfolio;

import java.time.Instant;

@Getter
@Setter
public class CryptocurrencyDto {
    private String fullName;
    private String shortName;
    private Double amount;
    private Instant addedAt;
    private Double buyPrice;
    private Portfolio portfolio;
}
