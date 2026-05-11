package br.edu.tarefascompartilhadas.repository;

import br.edu.tarefascompartilhadas.model.Tarefa;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TarefaRepository extends JpaRepository<Tarefa, Long> {

    List<Tarefa> findByUsuarioCriadorId(Long usuarioId);
}
