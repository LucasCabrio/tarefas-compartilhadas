package br.edu.tarefascompartilhadas.service;

import br.edu.tarefascompartilhadas.enums.StatusAmizade;
import br.edu.tarefascompartilhadas.model.Amizade;
import br.edu.tarefascompartilhadas.model.Usuario;
import br.edu.tarefascompartilhadas.repository.AmizadeRepository;
import br.edu.tarefascompartilhadas.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AmizadeService {

    private final AmizadeRepository amizadeRepository;
    private final UsuarioRepository usuarioRepository;

    public Amizade criar(Amizade amizade) {
        Long solicitanteId = extrairUsuarioId(
                amizade.getUsuarioSolicitante(),
                "Usuario solicitante e obrigatorio."
        );

        Long amigoId = extrairUsuarioId(
                amizade.getUsuarioAmigo(),
                "Usuario amigo e obrigatorio."
        );

        if (solicitanteId.equals(amigoId)) {
            throw new RuntimeException("Nao e permitido criar amizade do usuario com ele mesmo.");
        }

        if (amizadeRepository.existsByUsuarios(solicitanteId, amigoId)) {
            throw new RuntimeException("Ja existe solicitacao ou amizade entre estes usuarios.");
        }

        Usuario solicitante = buscarUsuario(solicitanteId);
        Usuario amigo = buscarUsuario(amigoId);

        amizade.setId(null);
        amizade.setUsuarioSolicitante(solicitante);
        amizade.setUsuarioAmigo(amigo);
        amizade.setStatusAmizade(StatusAmizade.PENDENTE);
        amizade.setDataSolicitacao(LocalDateTime.now());

        return amizadeRepository.save(amizade);
    }

    public List<Amizade> listar() {
        return amizadeRepository.findAll();
    }

    public Amizade buscarPorId(Long id) {
        return amizadeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Amizade nao encontrada."));
    }

    public List<Amizade> listarAmigos(Long usuarioId) {
        buscarUsuario(usuarioId);
        return amizadeRepository.findByUsuarioIdAndStatus(usuarioId, StatusAmizade.ACEITA);
    }

    public List<Amizade> listarSolicitacoes(Long usuarioId) {
        buscarUsuario(usuarioId);
        return amizadeRepository.findByUsuarioAmigoIdAndStatusAmizade(
                usuarioId,
                StatusAmizade.PENDENTE
        );
    }

    public Amizade aceitar(Long id, Long usuarioLogadoId) {
        Amizade amizade = buscarPorId(id);

        validarUsuarioPodeResponder(amizade, usuarioLogadoId);

        if (amizade.getStatusAmizade() != StatusAmizade.PENDENTE) {
            throw new RuntimeException("Apenas solicitacoes pendentes podem ser aceitas.");
        }

        amizade.setStatusAmizade(StatusAmizade.ACEITA);
        return amizadeRepository.save(amizade);
    }

    public Amizade recusar(Long id, Long usuarioLogadoId) {
        Amizade amizade = buscarPorId(id);

        validarUsuarioPodeResponder(amizade, usuarioLogadoId);

        if (amizade.getStatusAmizade() != StatusAmizade.PENDENTE) {
            throw new RuntimeException("Apenas solicitacoes pendentes podem ser recusadas.");
        }

        amizade.setStatusAmizade(StatusAmizade.RECUSADA);
        return amizadeRepository.save(amizade);
    }

    public void deletar(Long id) {
        Amizade amizade = buscarPorId(id);
        amizadeRepository.delete(amizade);
    }

    private void validarUsuarioPodeResponder(Amizade amizade, Long usuarioLogadoId) {
        if (usuarioLogadoId == null) {
            throw new RuntimeException("Usuario logado e obrigatorio para responder a solicitacao.");
        }

        buscarUsuario(usuarioLogadoId);

        if (amizade.getUsuarioAmigo() == null || amizade.getUsuarioAmigo().getId() == null) {
            throw new RuntimeException("Nao foi possivel identificar o destinatario da solicitacao.");
        }

        if (!amizade.getUsuarioAmigo().getId().equals(usuarioLogadoId)) {
            throw new RuntimeException("Apenas o destinatario da solicitacao pode aceitar ou recusar.");
        }
    }

    private Usuario buscarUsuario(Long id) {
        return usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario nao encontrado."));
    }

    private Long extrairUsuarioId(Usuario usuario, String mensagemErro) {
        if (usuario == null || usuario.getId() == null) {
            throw new RuntimeException(mensagemErro);
        }

        return usuario.getId();
    }
}