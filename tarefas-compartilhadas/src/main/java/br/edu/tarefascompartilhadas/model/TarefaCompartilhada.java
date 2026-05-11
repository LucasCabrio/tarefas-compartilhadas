package br.edu.tarefascompartilhadas.model;

import br.edu.tarefascompartilhadas.enums.PermissaoTarefa;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Transient;
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
public class TarefaCompartilhada {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "tarefa_id", nullable = false)
    private Tarefa tarefa;

    @ManyToOne
    @JoinColumn(name = "usuario_compartilhado_id", nullable = false)
    private Usuario usuarioCompartilhado;

    @Enumerated(EnumType.STRING)
    private PermissaoTarefa permissao;

    private LocalDateTime dataCompartilhamento;

    @Transient
    private Long usuarioCriadorId;

    @PrePersist
    public void prePersist() {
        if (dataCompartilhamento == null) {
            dataCompartilhamento = LocalDateTime.now();
        }
    }
}
