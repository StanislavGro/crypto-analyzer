package ru.youngstanis.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.youngstanis.models.Portfolio;
import ru.youngstanis.services.PortfolioService;

import java.util.List;

@RestController
@RequestMapping("/api/v1/portfolio")
public class PortfolioController {

    private final PortfolioService portfolioService;

    public PortfolioController(PortfolioService portfolioService) {
        this.portfolioService = portfolioService;
    }

    @GetMapping("/getAllPortfolios")
    public String getAllPortfolios() {
        return "[\"Portfolio 1\", \"Portfolio 2\"]";
    }
}
