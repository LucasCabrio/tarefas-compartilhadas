package br.edu.tarefascompartilhadas.service;

import br.edu.tarefascompartilhadas.enums.PermissaoTarefa;
import br.edu.tarefascompartilhadas.enums.PrioridadeTarefa;
import br.edu.tarefascompartilhadas.enums.StatusTarefa;
import br.edu.tarefascompartilhadas.model.HistoricoStatus;
import br.edu.tarefascompartilhadas.model.Tarefa;
import br.edu.tarefascompartilhadas.model.TarefaCompartilhada;
import br.edu.tarefascompartilhadas.model.Usuario;
import br.edu.tarefascompartilhadas.repository.HistoricoStatusRepository;
import br.edu.tarefascompartilhadas.repository.TarefaCompartilhadaRepository;
import br.edu.tarefascompartilhadas.repository.TarefaRepository;
import br.edu.tarefascompartilhadas.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TarefaService {

    private final TarefaRepository tarefaRepository;
    private final UsuarioRepository usuarioRepository;
    private final TarefaCompartilhadaRepository tarefaCompartilhadaRepository;
    private final HistoricoStatusRepository historicoStatusRepository;

    public Tarefa criar(Tarefa tarefa) {
        Long usuarioCriadorId = extrairUsuarioCriadorId(tarefa);
        Usuario usuarioCriador = buscarUsuario(usuarioCriadorId);

        if (tarefa.getUsuarioResponsavelId() != null) {
            buscarUsuario(tarefa.getUsuarioResponsavelId());
        }

        tarefa.setId(null);
        tarefa.setUsuarioCriador(usuarioCriador);
        tarefa.setDataCriacao(LocalDateTime.now());

        if (tarefa.getStatusAtual() == null) {
            tarefa.setStatusAtual(StatusTarefa.PENDENTE);
        }

        return tarefaRepository.save(tarefa);
    }

    public List<Tarefa> listar() {
        return tarefaRepository.findAll();
    }

    public Tarefa buscarPorId(Long id) {
        return tarefaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tarefa nao encontrada."));
    }

    public List<Tarefa> listarPorUsuario(Long usuarioId) {
        buscarUsuario(usuarioId);
        return tarefaRepository.findByUsuarioCriadorId(usuarioId);
    }

    public Tarefa atualizar(
            Long id,
            Long usuarioLogadoId,
            String titulo,
            String descricao,
            StatusTarefa statusAtual,
            PrioridadeTarefa prioridade,
            LocalDateTime dataLimite,
            Long usuarioResponsavelId) {

        Tarefa tarefa = buscarPorId(id);
        Usuario usuarioLogado = buscarUsuarioObrigatorio(
                usuarioLogadoId,
                "Usuario logado e obrigatorio para editar a tarefa."
        );

        if (!podeEditarTarefa(tarefa, usuarioLogado.getId())) {
            throw new RuntimeException("Usuario nao possui permissao para editar esta tarefa.");
        }

        if (usuarioResponsavelId != null) {
            buscarUsuario(usuarioResponsavelId);
        }

        tarefa.setTitulo(titulo);
        tarefa.setDescricao(descricao);
        tarefa.setPrioridade(prioridade);
        tarefa.setDataLimite(dataLimite);
        tarefa.setUsuarioResponsavelId(usuarioResponsavelId);

        if (statusAtual != null) {
            atualizarStatusComHistorico(tarefa, usuarioLogado, statusAtual);
        }

        return tarefaRepository.save(tarefa);
    }

    public Tarefa alterarStatus(Long id, Long usuarioId, StatusTarefa statusNovo) {
        if (statusNovo == null) {
            throw new RuntimeException("Novo status e obrigatorio.");
        }

        Tarefa tarefa = buscarPorId(id);
        Usuario usuario = buscarUsuarioObrigatorio(
                usuarioId,
                "Usuario logado e obrigatorio para alterar o status."
        );

        if (!podeAlterarStatus(tarefa, usuario.getId())) {
            throw new RuntimeException("Usuario nao possui permissao para alterar o status desta tarefa.");
        }

        atualizarStatusComHistorico(tarefa, usuario, statusNovo);
        return tarefaRepository.save(tarefa);
    }

    public void deletar(Long id) {
        Tarefa tarefa = buscarPorId(id);
        tarefaRepository.delete(tarefa);
    }

    public boolean usuarioPodeAcessarTarefa(Tarefa tarefa, Long usuarioId) {
        return tarefa.getUsuarioCriador().getId().equals(usuarioId)
                || tarefaCompartilhadaRepository.existsByTarefaIdAndUsuarioCompartilhadoId(
                tarefa.getId(),
                usuarioId
        );
    }

    private boolean podeEditarTarefa(Tarefa tarefa, Long usuarioId) {
        if (tarefa.getUsuarioCriador().getId().equals(usuarioId)) {
            return true;
        }

        return tarefaCompartilhadaRepository.findByTarefaIdAndUsuarioCompartilhadoId(
                        tarefa.getId(),
                        usuarioId
                )
                .map(compartilhamento -> compartilhamento.getPermissao() == PermissaoTarefa.EDITAR_TAREFA)
                .orElse(false);
    }

    private boolean podeAlterarStatus(Tarefa tarefa, Long usuarioId) {
        if (tarefa.getUsuarioCriador().getId().equals(usuarioId)) {
            return true;
        }

        return tarefaCompartilhadaRepository.findByTarefaIdAndUsuarioCompartilhadoId(
                        tarefa.getId(),
                        usuarioId
                )
                .map(this::possuiPermissaoParaAlterarStatus)
                .orElse(false);
    }

    private boolean possuiPermissaoParaAlterarStatus(TarefaCompartilhada compartilhamento) {
        return compartilhamento.getPermissao() == PermissaoTarefa.EDITAR_STATUS
                || compartilhamento.getPermissao() == PermissaoTarefa.EDITAR_TAREFA;
    }

    private void atualizarStatusComHistorico(Tarefa tarefa, Usuario usuario, StatusTarefa statusNovo) {
        StatusTarefa statusAnterior = tarefa.getStatusAtual();

        if (statusAnterior == statusNovo) {
            return;
        }

        tarefa.setStatusAtual(statusNovo);

        HistoricoStatus historico = new HistoricoStatus();
        historico.setTarefa(tarefa);
        historico.setUsuario(usuario);
        historico.setStatusAnterior(statusAnterior);
        historico.setStatusNovo(statusNovo);
        historico.setDataAlteracao(LocalDateTime.now());

        historicoStatusRepository.save(historico);
    }

    private Long extrairUsuarioCriadorId(Tarefa tarefa) {
        if (tarefa.getUsuarioCriador() == null || tarefa.getUsuarioCriador().getId() == null) {
            throw new RuntimeException("Usuario criador da tarefa e obrigatorio.");
        }

        return tarefa.getUsuarioCriador().getId();
    }

    private Usuario buscarUsuarioObrigatorio(Long usuarioId, String mensagemErro) {
        if (usuarioId == null) {
            throw new RuntimeException(mensagemErro);
        }

        return buscarUsuario(usuarioId);
    }

    private Usuario buscarUsuario(Long usuarioId) {
        return usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new RuntimeException("Usuario nao encontrado."));
    }
}