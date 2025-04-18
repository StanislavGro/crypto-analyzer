package ru.youngstanis.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ru.youngstanis.dto.CryptocurrencyDto;
import ru.youngstanis.models.Cryptocurrency;
import ru.youngstanis.services.CryptocurrencyService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/cryptocurrency")
public class CryptocurrencyController {

    private final CryptocurrencyService cryptocurrencyService;

    public CryptocurrencyController(final CryptocurrencyService cryptocurrencyService) {
        this.cryptocurrencyService = cryptocurrencyService;
    }

    @GetMapping("/get-user-cryptocurrencies/{userId}")
    public ResponseEntity<List<CryptocurrencyDto>> getUserCryptocurrencies(@PathVariable UUID userId) {
        List<CryptocurrencyDto> cryptocurrencyDtos = cryptocurrencyService.getAllUserCryptocurrency(userId);
        return ResponseEntity.ok(cryptocurrencyDtos);
    }

    @PostMapping("/add-cryptocurrency")
    public ResponseEntity<HttpStatus> addCryptocurrency(@RequestBody CryptocurrencyDto cryptocurrencyDto) {
        //TODO
        return ResponseEntity.ok(HttpStatus.CREATED);
    }

    @PostMapping("/delete-cryptocurrency")
    public ResponseEntity<?> deleteCryptocurrency() {
        //TODO
        return ResponseEntity.ok(HttpStatus.CREATED);
    }

    @PostMapping("/update-cryptocurrency")
    public ResponseEntity<?> updateCryptocurrency() {
        //TODO
        return ResponseEntity.ok(HttpStatus.CREATED);
    }
}
