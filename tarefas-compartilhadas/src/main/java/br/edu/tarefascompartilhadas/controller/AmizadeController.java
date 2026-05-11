package br.edu.tarefascompartilhadas.controller;

import br.edu.tarefascompartilhadas.model.Amizade;
import br.edu.tarefascompartilhadas.service.AmizadeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class AmizadeController {

    private final AmizadeService amizadeService;

    @PostMapping("/amizades")
    public ResponseEntity<Amizade> criar(@RequestBody Amizade amizade) {
        return ResponseEntity.status(HttpStatus.CREATED).body(amizadeService.criar(amizade));
    }

    @GetMapping("/amizades")
    public ResponseEntity<List<Amizade>> listar() {
        return ResponseEntity.ok(amizadeService.listar());
    }

    @GetMapping("/amizades/{id}")
    public ResponseEntity<Amizade> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(amizadeService.buscarPorId(id));
    }

    @GetMapping("/usuarios/{id}/amigos")
    public ResponseEntity<List<Amizade>> listarAmigos(@PathVariable Long id) {
        return ResponseEntity.ok(amizadeService.listarAmigos(id));
    }

    @GetMapping("/usuarios/{id}/solicitacoes")
    public ResponseEntity<List<Amizade>> listarSolicitacoes(@PathVariable Long id) {
        return ResponseEntity.ok(amizadeService.listarSolicitacoes(id));
    }

    @PutMapping("/amizades/{id}/aceitar")
    public ResponseEntity<Amizade> aceitar(
            @PathVariable Long id,
            @RequestBody ResponderAmizadeRequest request) {

        return ResponseEntity.ok(
                amizadeService.aceitar(id, request.usuarioLogadoId())
        );
    }

    @PutMapping("/amizades/{id}/recusar")
    public ResponseEntity<Amizade> recusar(
            @PathVariable Long id,
            @RequestBody ResponderAmizadeRequest request) {

        return ResponseEntity.ok(
                amizadeService.recusar(id, request.usuarioLogadoId())
        );
    }

    @DeleteMapping("/amizades/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        amizadeService.deletar(id);
        return ResponseEntity.noContent().build();
    }

    public record ResponderAmizadeRequest(Long usuarioLogadoId) {
    }
}