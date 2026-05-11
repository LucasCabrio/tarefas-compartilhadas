package br.edu.tarefascompartilhadas.repository;

import br.edu.tarefascompartilhadas.model.TarefaCompartilhada;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface TarefaCompartilhadaRepository extends JpaRepository<TarefaCompartilhada, Long> {

    List<TarefaCompartilhada> findByUsuarioCompartilhadoId(Long usuarioId);

    List<TarefaCompartilhada> findByTarefaId(Long tarefaId);

    Optional<TarefaCompartilhada> findByTarefaIdAndUsuarioCompartilhadoId(Long tarefaId, Long usuarioId);

    boolean existsByTarefaIdAndUsuarioCompartilhadoId(Long tarefaId, Long usuarioId);
}
