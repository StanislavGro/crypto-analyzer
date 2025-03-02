package ru.youngstanis.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;
import ru.youngstanis.constants.DatabaseNames;

@Entity
@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder(setterPrefix = "with")
@Table(name = DatabaseNames.PORTFOLIO)
public class Portfolio {
    @Id
    private Long id;

    @Column(name = "portfolio_name")
    private String portfolioName;
}
