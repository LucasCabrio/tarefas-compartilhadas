package br.edu.tarefascompartilhadas.repository;

import br.edu.tarefascompartilhadas.model.ComentarioTarefa;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ComentarioTarefaRepository extends JpaRepository<ComentarioTarefa, Long> {

    List<ComentarioTarefa> findByTarefaIdOrderByDataComentarioAsc(Long tarefaId);
}
