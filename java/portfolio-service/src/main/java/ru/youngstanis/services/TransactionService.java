package ru.youngstanis.services;

import org.springframework.stereotype.Service;
import ru.youngstanis.repository.TransactionRepository;

@Service
public class TransactionService {

    private final TransactionRepository transactionRepository;

    public TransactionService(TransactionRepository transactionRepository) {
        this.transactionRepository = transactionRepository;
    }
}
