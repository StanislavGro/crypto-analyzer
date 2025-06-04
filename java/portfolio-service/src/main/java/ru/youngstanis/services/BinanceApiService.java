package ru.youngstanis.services;

import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
public class BinanceApiService {

    private final WebClient webClient;
    private static final String BINANCE_API_URL = "https://api.binance.com";

    public BinanceApiService() {
        this.webClient = WebClient.create(BINANCE_API_URL);
    }

    public Mono<String> getCryptocurrencyPrice(String baseCurrency, String quoteCurrency) {
        String symbol = baseCurrency.toUpperCase() + quoteCurrency.toUpperCase();

        return webClient.get()
                .uri("/api/v3/ticker/price?symbol=" + symbol)
                .retrieve()
                .bodyToMono(String.class);
    }
}
