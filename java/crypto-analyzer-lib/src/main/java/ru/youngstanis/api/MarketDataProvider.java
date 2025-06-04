package ru.youngstanis.api;

import ru.youngstanis.models.CoinPrice;
import ru.youngstanis.models.MarketSummary;

import java.util.List;

public interface MarketDataProvider {
    CoinPrice getPrice(String symbol);
    MarketSummary getMarketSummary(String symbol);
    List<CoinPrice> getHistoricalPrices(String symbol, int limit);
}
