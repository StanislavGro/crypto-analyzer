package ru.youngstanis.models;

import jakarta.persistence.*;
import lombok.*;
import ru.youngstanis.constants.TableNames;

import java.util.List;

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

    @OneToMany(mappedBy = "portfolio")
    private List<Cryptocurrency> cryptocurrencies;
}
