package br.edu.tarefascompartilhadas.service;

import br.edu.tarefascompartilhadas.model.Usuario;
import br.edu.tarefascompartilhadas.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;

    public Usuario criar(Usuario usuario) {
        if (usuario.getEmail() == null || usuario.getEmail().isBlank()) {
            throw new RuntimeException("E-mail do usuario e obrigatorio.");
        }
        if (usuarioRepository.existsByEmail(usuario.getEmail())) {
            throw new RuntimeException("Ja existe usuario cadastrado com este e-mail.");
        }
        usuario.setId(null);
        return usuarioRepository.save(usuario);
    }

    public List<Usuario> listar() {
        return usuarioRepository.findAll();
    }

    public Usuario buscarPorId(Long id) {
        return usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario nao encontrado."));
    }

    public Usuario atualizar(Long id, Usuario dados) {
        Usuario usuario = buscarPorId(id);

        if (dados.getEmail() != null && !dados.getEmail().equals(usuario.getEmail())) {
            usuarioRepository.findByEmail(dados.getEmail()).ifPresent(usuarioExistente -> {
                throw new RuntimeException("Ja existe usuario cadastrado com este e-mail.");
            });
        }

        usuario.setNome(dados.getNome());
        usuario.setEmail(dados.getEmail());
        usuario.setSenha(dados.getSenha());
        usuario.setTelefone(dados.getTelefone());

        return usuarioRepository.save(usuario);
    }

    public void deletar(Long id) {
        Usuario usuario = buscarPorId(id);
        usuarioRepository.delete(usuario);
    }
}
