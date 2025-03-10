package ru.youngstanis.models;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;
import ru.youngstanis.constants.TableNames;

import java.util.List;
import java.util.UUID;

@Entity
@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder(setterPrefix = "with")
@Table(name = TableNames.PORTFOLIO)
public class Portfolio {
    @Id
    private Long id;

    @Column(name = "portfolio_name")
    private String portfolioName;

    @Column(name = "user_id")
    private UUID userId;

    @OneToMany(mappedBy = "portfolio")
    @JsonBackReference
    private List<Cryptocurrency> cryptocurrencies;
}
