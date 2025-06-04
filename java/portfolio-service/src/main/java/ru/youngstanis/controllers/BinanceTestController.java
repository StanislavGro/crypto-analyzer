package ru.youngstanis.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;
import ru.youngstanis.services.BinanceApiService;

@RestController
@RequestMapping("/api/v1/binanceApiTest")
public class BinanceTestController {

    private final BinanceApiService binanceApiService;

    public BinanceTestController(BinanceApiService binanceApiService) {
        this.binanceApiService = binanceApiService;
    }

    @GetMapping("/getCryptocurrencyPrice")
    public Mono<String> getCryptocurrencyPrice(@RequestParam("baseCurrency") String baseCurrency, @RequestParam("quoteCurrency") String quoteCurrency) {
        return binanceApiService.getCryptocurrencyPrice(baseCurrency, quoteCurrency);
    }
}
