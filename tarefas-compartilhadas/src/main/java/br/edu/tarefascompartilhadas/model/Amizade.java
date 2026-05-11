package br.edu.tarefascompartilhadas.model;

import br.edu.tarefascompartilhadas.enums.StatusAmizade;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Amizade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "usuario_solicitante_id", nullable = false)
    private Usuario usuarioSolicitante;

    @ManyToOne
    @JoinColumn(name = "usuario_amigo_id", nullable = false)
    private Usuario usuarioAmigo;

    @Enumerated(EnumType.STRING)
    private StatusAmizade statusAmizade;

    private LocalDateTime dataSolicitacao;

    @PrePersist
    public void prePersist() {
        if (statusAmizade == null) {
            statusAmizade = StatusAmizade.PENDENTE;
        }
        if (dataSolicitacao == null) {
            dataSolicitacao = LocalDateTime.now();
        }
    }
}
