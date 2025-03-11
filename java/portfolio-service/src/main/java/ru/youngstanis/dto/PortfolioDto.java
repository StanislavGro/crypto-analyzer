package ru.youngstanis.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class PortfolioDto {
    private String portfolioName;
    private UUID userId;
}
