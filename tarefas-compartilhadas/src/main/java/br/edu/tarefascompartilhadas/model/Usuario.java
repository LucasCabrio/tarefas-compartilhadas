package br.edu.tarefascompartilhadas.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nome;

    @Column(nullable = false, unique = true)
    private String email;

    private String senha;

    private String telefone;

    @JsonIgnore
    @OneToMany(mappedBy = "usuarioCriador")
    private List<Tarefa> tarefasCriadas;

    @JsonIgnore
    @OneToMany(mappedBy = "usuarioSolicitante")
    private List<Amizade> amizadesSolicitadas;

    @JsonIgnore
    @OneToMany(mappedBy = "usuarioAmigo")
    private List<Amizade> amizadesRecebidas;

    @JsonIgnore
    @OneToMany(mappedBy = "usuarioCompartilhado")
    private List<TarefaCompartilhada> tarefasCompartilhadas;

    @JsonIgnore
    @OneToMany(mappedBy = "usuario")
    private List<ComentarioTarefa> comentarios;

    @JsonIgnore
    @OneToMany(mappedBy = "usuario")
    private List<HistoricoStatus> historicosStatus;
}
