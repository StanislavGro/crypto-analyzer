package ru.youngstanis.models;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.GenericGenerator;

import java.util.List;
import java.util.UUID;

import static ru.youngstanis.constants.TableNames.*;

@Entity
@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder(setterPrefix = "with")
@Table(name = PORTFOLIO)
public class Portfolio {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    private Long id;

    @Column(name = "portfolio_name")
    private String portfolioName;

    @Column(name = "user_id")
    private UUID userId;

    @OneToMany(mappedBy = "portfolio")
    @JsonBackReference
    private List<Cryptocurrency> cryptocurrencies;
}
