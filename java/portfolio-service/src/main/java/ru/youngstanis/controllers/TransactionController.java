package ru.youngstanis.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.youngstanis.models.Cryptocurrency;
import ru.youngstanis.services.TransactionService;

@RestController
@RequestMapping("/api/v1/transaction")
public class TransactionController {

    private final TransactionService transactionService;

    public TransactionController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }

    @PostMapping("/add-transaction")
    public ResponseEntity<?> addCryptocurrency(@RequestBody Cryptocurrency cryptocurrency) {
        //TODO
        return ResponseEntity.ok(HttpStatus.CREATED);
    }

    @PostMapping("/delete-transaction")
    public ResponseEntity<?> deleteTransaction() {
        //TODO
        return ResponseEntity.ok(HttpStatus.CREATED);
    }

    @PostMapping("/update-transaction")
    public ResponseEntity<?> updateTransaction() {
        //TODO
        return ResponseEntity.ok(HttpStatus.CREATED);
    }
}
