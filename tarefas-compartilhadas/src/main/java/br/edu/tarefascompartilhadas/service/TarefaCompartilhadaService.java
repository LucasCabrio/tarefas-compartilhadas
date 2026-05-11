package br.edu.tarefascompartilhadas.service;

import br.edu.tarefascompartilhadas.enums.PermissaoTarefa;
import br.edu.tarefascompartilhadas.enums.StatusAmizade;
import br.edu.tarefascompartilhadas.model.Tarefa;
import br.edu.tarefascompartilhadas.model.TarefaCompartilhada;
import br.edu.tarefascompartilhadas.model.Usuario;
import br.edu.tarefascompartilhadas.repository.AmizadeRepository;
import br.edu.tarefascompartilhadas.repository.TarefaCompartilhadaRepository;
import br.edu.tarefascompartilhadas.repository.TarefaRepository;
import br.edu.tarefascompartilhadas.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TarefaCompartilhadaService {

    private final TarefaCompartilhadaRepository tarefaCompartilhadaRepository;
    private final TarefaRepository tarefaRepository;
    private final UsuarioRepository usuarioRepository;
    private final AmizadeRepository amizadeRepository;

    public TarefaCompartilhada criar(TarefaCompartilhada compartilhamento, Long usuarioCriadorId) {
        Tarefa tarefa = buscarTarefa(extrairTarefaId(compartilhamento));
        Usuario usuarioCompartilhado = buscarUsuario(extrairUsuarioCompartilhadoId(compartilhamento));

        if (usuarioCriadorId == null) {
            throw new RuntimeException("ID do criador da tarefa e obrigatorio.");
        }

        if (!tarefa.getUsuarioCriador().getId().equals(usuarioCriadorId)) {
            throw new RuntimeException("Apenas o criador da tarefa pode compartilha-la.");
        }

        if (compartilhamento.getPermissao() == null) {
            throw new RuntimeException("Permissao e obrigatoria.");
        }

        if (!amizadeRepository.existsByUsuariosAndStatus(
                usuarioCriadorId,
                usuarioCompartilhado.getId(),
                StatusAmizade.ACEITA)) {
            throw new RuntimeException("A tarefa so pode ser compartilhada com amigo aceito.");
        }

        if (tarefaCompartilhadaRepository.existsByTarefaIdAndUsuarioCompartilhadoId(
                tarefa.getId(),
                usuarioCompartilhado.getId())) {
            throw new RuntimeException("Esta tarefa ja foi compartilhada com este usuario.");
        }

        compartilhamento.setId(null);
        compartilhamento.setTarefa(tarefa);
        compartilhamento.setUsuarioCompartilhado(usuarioCompartilhado);
        compartilhamento.setDataCompartilhamento(LocalDateTime.now());

        return tarefaCompartilhadaRepository.save(compartilhamento);
    }

    public List<TarefaCompartilhada> listar() {
        return tarefaCompartilhadaRepository.findAll();
    }

    public TarefaCompartilhada buscarPorId(Long id) {
        return tarefaCompartilhadaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Compartilhamento nao encontrado."));
    }

    public List<TarefaCompartilhada> listarPorUsuario(Long usuarioId) {
        buscarUsuario(usuarioId);
        return tarefaCompartilhadaRepository.findByUsuarioCompartilhadoId(usuarioId);
    }

    public List<TarefaCompartilhada> listarPorTarefa(Long tarefaId) {
        buscarTarefa(tarefaId);
        return tarefaCompartilhadaRepository.findByTarefaId(tarefaId);
    }

    public TarefaCompartilhada atualizarPermissao(Long id, Long usuarioLogadoId, PermissaoTarefa permissao) {
        if (usuarioLogadoId == null) {
            throw new RuntimeException("Usuario logado e obrigatorio para alterar permissao.");
        }

        if (permissao == null) {
            throw new RuntimeException("Permissao e obrigatoria.");
        }

        TarefaCompartilhada compartilhamento = buscarPorId(id);

        Tarefa tarefa = compartilhamento.getTarefa();

        if (tarefa == null || tarefa.getUsuarioCriador() == null || tarefa.getUsuarioCriador().getId() == null) {
            throw new RuntimeException("Nao foi possivel identificar o criador da tarefa.");
        }

        if (!tarefa.getUsuarioCriador().getId().equals(usuarioLogadoId)) {
            throw new RuntimeException("Apenas o criador da tarefa pode alterar a permissao.");
        }

        compartilhamento.setPermissao(permissao);

        return tarefaCompartilhadaRepository.save(compartilhamento);
    }

    public void deletar(Long id) {
        TarefaCompartilhada compartilhamento = buscarPorId(id);
        tarefaCompartilhadaRepository.delete(compartilhamento);
    }

    private Tarefa buscarTarefa(Long tarefaId) {
        return tarefaRepository.findById(tarefaId)
                .orElseThrow(() -> new RuntimeException("Tarefa nao encontrada."));
    }

    private Usuario buscarUsuario(Long usuarioId) {
        return usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new RuntimeException("Usuario nao encontrado."));
    }

    private Long extrairTarefaId(TarefaCompartilhada compartilhamento) {
        if (compartilhamento.getTarefa() == null || compartilhamento.getTarefa().getId() == null) {
            throw new RuntimeException("Tarefa e obrigatoria.");
        }

        return compartilhamento.getTarefa().getId();
    }

    private Long extrairUsuarioCompartilhadoId(TarefaCompartilhada compartilhamento) {
        if (compartilhamento.getUsuarioCompartilhado() == null
                || compartilhamento.getUsuarioCompartilhado().getId() == null) {
            throw new RuntimeException("Usuario compartilhado e obrigatorio.");
        }

        return compartilhamento.getUsuarioCompartilhado().getId();
    }
}