package ru.youngstanis.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.youngstanis.models.Portfolio;

public interface PortfolioRepository extends JpaRepository<Portfolio, Long> {
}
