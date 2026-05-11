package br.edu.tarefascompartilhadas.repository;

import br.edu.tarefascompartilhadas.model.HistoricoStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HistoricoStatusRepository extends JpaRepository<HistoricoStatus, Long> {

    List<HistoricoStatus> findByTarefaIdOrderByDataAlteracaoAsc(Long tarefaId);
}
