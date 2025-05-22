//package ru.youngstanis.api.impl;
//
//import ru.youngstanis.api.MarketDataProvider;
//import ru.youngstanis.models.CoinPrice;
//import ru.youngstanis.models.MarketSummary;
//
//import java.net.http.HttpClient;
//import java.util.List;
//
//public class CoinMarketCapProvider implements MarketDataProvider {
//
//    private static final String API_URL = "https://pro-api.coinmarketcap.com/v1";
//    private final String apiKey;
//    private final HttpClient httpClient;
//    private final ObjectMapper objectMapper;
//
//    @Override
//    public CoinPrice getPrice(String symbol) {
//        return null;
//    }
//
//    @Override
//    public MarketSummary getMarketSummary(String symbol) {
//        return null;
//    }
//
//    @Override
//    public List<CoinPrice> getHistoricalPrices(String symbol, int limit) {
//        return List.of();
//    }
//}
