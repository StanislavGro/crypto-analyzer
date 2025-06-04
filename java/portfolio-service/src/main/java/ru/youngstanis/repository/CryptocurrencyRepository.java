package ru.youngstanis.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import ru.youngstanis.models.Cryptocurrency;

import java.util.List;
import java.util.UUID;

@Repository
public interface CryptocurrencyRepository extends JpaRepository<Cryptocurrency, Long> {

    @Query(value = "SELECT psc.*" +
            "FROM portfolio_service_cryptocurrencies psc " +
            "JOIN portfolio_service_portfolio psp " +
            "ON psc.portfolio_id = psp.id " +
            "WHERE psp.user_id = :userId", nativeQuery = true
    )
    List<Cryptocurrency> getAllByUserId(@Param("userId") UUID userId);
}
