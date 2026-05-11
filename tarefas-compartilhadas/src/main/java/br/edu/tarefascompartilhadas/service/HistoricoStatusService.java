package br.edu.tarefascompartilhadas.service;

import br.edu.tarefascompartilhadas.model.HistoricoStatus;
import br.edu.tarefascompartilhadas.repository.HistoricoStatusRepository;
import br.edu.tarefascompartilhadas.repository.TarefaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class HistoricoStatusService {

    private final HistoricoStatusRepository historicoStatusRepository;
    private final TarefaRepository tarefaRepository;

    public List<HistoricoStatus> listar() {
        return historicoStatusRepository.findAll();
    }

    public HistoricoStatus buscarPorId(Long id) {
        return historicoStatusRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Historico de status nao encontrado."));
    }

    public List<HistoricoStatus> listarPorTarefa(Long tarefaId) {
        if (!tarefaRepository.existsById(tarefaId)) {
            throw new RuntimeException("Tarefa nao encontrada.");
        }
        return historicoStatusRepository.findByTarefaIdOrderByDataAlteracaoAsc(tarefaId);
    }
}
