package ru.youngstanis.services;

import org.springframework.stereotype.Service;
import ru.youngstanis.models.Portfolio;
import ru.youngstanis.repository.PortfolioRepository;

import java.util.List;

@Service
public class PortfolioService {
    private final PortfolioRepository portfolioRepository;

    public PortfolioService(PortfolioRepository portfolioRepository) {
        this.portfolioRepository = portfolioRepository;
    }

    public List<Portfolio> getAllPortfolios() {
        return portfolioRepository.findAll();
    }
}
