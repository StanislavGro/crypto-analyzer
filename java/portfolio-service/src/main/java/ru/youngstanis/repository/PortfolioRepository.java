package ru.youngstanis.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import ru.youngstanis.models.Portfolio;

@Repository
public interface PortfolioRepository extends JpaRepository<Portfolio, Long> {
}
