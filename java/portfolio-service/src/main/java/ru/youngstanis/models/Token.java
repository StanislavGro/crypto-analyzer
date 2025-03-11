package ru.youngstanis.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.SecondaryRow;
import ru.youngstanis.constants.TableNames;

@Entity
@Getter
@SecondaryRow
@NoArgsConstructor
@AllArgsConstructor
@Table(name = TableNames.TOKENS)
public class Token {
    @Id
    private Long id;

    @Column(name = "token_name")
    private String tokenName;
}
