package br.edu.tarefascompartilhadas.model;

import br.edu.tarefascompartilhadas.enums.PrioridadeTarefa;
import br.edu.tarefascompartilhadas.enums.StatusTarefa;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Tarefa {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String titulo;

    @Column(length = 1000)
    private String descricao;

    @Enumerated(EnumType.STRING)
    private StatusTarefa statusAtual;

    @Enumerated(EnumType.STRING)
    private PrioridadeTarefa prioridade;

    private LocalDateTime dataCriacao;

    private LocalDateTime dataLimite;

    @ManyToOne
    @JoinColumn(name = "usuario_criador_id", nullable = false)
    private Usuario usuarioCriador;

    @Column(name = "usuario_responsavel_id")
    private Long usuarioResponsavelId;

    @JsonIgnore
    @OneToMany(mappedBy = "tarefa", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<TarefaCompartilhada> compartilhamentos;

    @JsonIgnore
    @OneToMany(mappedBy = "tarefa", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ComentarioTarefa> comentarios;

    @JsonIgnore
    @OneToMany(mappedBy = "tarefa", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<HistoricoStatus> historicosStatus;

    @PrePersist
    public void prePersist() {
        if (dataCriacao == null) {
            dataCriacao = LocalDateTime.now();
        }

        if (statusAtual == null) {
            statusAtual = StatusTarefa.PENDENTE;
        }
    }
}