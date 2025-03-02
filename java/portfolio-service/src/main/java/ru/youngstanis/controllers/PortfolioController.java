package ru.youngstanis.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
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
    public ResponseEntity<List<Portfolio>> getAllPortfolios() {
        return ResponseEntity.ok(portfolioService.getAllPortfolios());
    }

    @PostMapping("/addPortfolio")
    public ResponseEntity<HttpStatus> addPortfolio(@RequestBody Portfolio portfolio) {
        //TODO
        return ResponseEntity.ok(HttpStatus.CREATED);
    }
}
