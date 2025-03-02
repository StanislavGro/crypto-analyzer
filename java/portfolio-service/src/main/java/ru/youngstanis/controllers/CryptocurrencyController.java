package ru.youngstanis.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ru.youngstanis.models.Cryptocurrency;
import ru.youngstanis.services.CryptocurrencyService;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/v1/cryptocurrency")
public class CryptocurrencyController {

    private final CryptocurrencyService cryptocurrencyService;

    public CryptocurrencyController(final CryptocurrencyService cryptocurrencyService) {
        this.cryptocurrencyService = cryptocurrencyService;
    }

    @GetMapping("/getAllCryptocurrency")
    public ResponseEntity<List<Cryptocurrency>> getAllCryptocurrency() {
        //TODO
        return ResponseEntity.ok(new ArrayList<>());
    }

    @PostMapping("/addCryptocurrency")
    public ResponseEntity<HttpStatus> addCryptocurrency(@RequestBody Cryptocurrency cryptocurrency) {
        //TODO
        return ResponseEntity.ok(HttpStatus.CREATED);
    }
}
