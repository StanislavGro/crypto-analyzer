package ru.youngstanis.services;

import org.springframework.stereotype.Service;
import ru.youngstanis.repository.CryptocurrencyRepository;

/**
 * TODO
 * Добавить метод получения всех криптовалют по определенному портфелю (со средней ценой)
 * Получения всех криптовалют определенного пользователя (с суммой по каждой из них числа валют и средней ценой )
 * Получения всех
 */
@Service
public class CryptocurrencyService {
    private final CryptocurrencyRepository cryptocurrencyRepository;

    public CryptocurrencyService(CryptocurrencyRepository cryptocurrencyRepository) {
        this.cryptocurrencyRepository = cryptocurrencyRepository;
    }

}
