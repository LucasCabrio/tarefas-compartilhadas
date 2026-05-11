package br.edu.tarefascompartilhadas.service;

import br.edu.tarefascompartilhadas.model.ComentarioTarefa;
import br.edu.tarefascompartilhadas.model.Tarefa;
import br.edu.tarefascompartilhadas.model.Usuario;
import br.edu.tarefascompartilhadas.repository.ComentarioTarefaRepository;
import br.edu.tarefascompartilhadas.repository.TarefaCompartilhadaRepository;
import br.edu.tarefascompartilhadas.repository.TarefaRepository;
import br.edu.tarefascompartilhadas.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ComentarioTarefaService {

    private final ComentarioTarefaRepository comentarioTarefaRepository;
    private final TarefaRepository tarefaRepository;
    private final UsuarioRepository usuarioRepository;
    private final TarefaCompartilhadaRepository tarefaCompartilhadaRepository;

    public ComentarioTarefa criar(ComentarioTarefa comentario) {
        Tarefa tarefa = buscarTarefa(extrairTarefaId(comentario));
        Usuario usuario = buscarUsuario(extrairUsuarioId(comentario));

        if (comentario.getTexto() == null || comentario.getTexto().isBlank()) {
            throw new RuntimeException("Texto do comentario e obrigatorio.");
        }
        if (!podeComentar(tarefa, usuario.getId())) {
            throw new RuntimeException("Usuario nao possui permissao para comentar nesta tarefa.");
        }

        comentario.setId(null);
        comentario.setTarefa(tarefa);
        comentario.setUsuario(usuario);
        comentario.setDataComentario(LocalDateTime.now());

        return comentarioTarefaRepository.save(comentario);
    }

    public List<ComentarioTarefa> listar() {
        return comentarioTarefaRepository.findAll();
    }

    public ComentarioTarefa buscarPorId(Long id) {
        return comentarioTarefaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Comentario nao encontrado."));
    }

    public List<ComentarioTarefa> listarPorTarefa(Long tarefaId) {
        buscarTarefa(tarefaId);
        return comentarioTarefaRepository.findByTarefaIdOrderByDataComentarioAsc(tarefaId);
    }

    public void deletar(Long id) {
        ComentarioTarefa comentario = buscarPorId(id);
        comentarioTarefaRepository.delete(comentario);
    }

    private boolean podeComentar(Tarefa tarefa, Long usuarioId) {
        return tarefa.getUsuarioCriador().getId().equals(usuarioId)
                || tarefaCompartilhadaRepository.existsByTarefaIdAndUsuarioCompartilhadoId(tarefa.getId(), usuarioId);
    }

    private Tarefa buscarTarefa(Long tarefaId) {
        return tarefaRepository.findById(tarefaId)
                .orElseThrow(() -> new RuntimeException("Tarefa nao encontrada."));
    }

    private Usuario buscarUsuario(Long usuarioId) {
        return usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new RuntimeException("Usuario nao encontrado."));
    }

    private Long extrairTarefaId(ComentarioTarefa comentario) {
        if (comentario.getTarefa() == null || comentario.getTarefa().getId() == null) {
            throw new RuntimeException("Tarefa e obrigatoria.");
        }
        return comentario.getTarefa().getId();
    }

    private Long extrairUsuarioId(ComentarioTarefa comentario) {
        if (comentario.getUsuario() == null || comentario.getUsuario().getId() == null) {
            throw new RuntimeException("Usuario e obrigatorio.");
        }
        return comentario.getUsuario().getId();
    }
}
