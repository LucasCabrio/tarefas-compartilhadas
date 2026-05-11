package br.edu.tarefascompartilhadas.controller;

import br.edu.tarefascompartilhadas.enums.PermissaoTarefa;
import br.edu.tarefascompartilhadas.model.TarefaCompartilhada;
import br.edu.tarefascompartilhadas.service.TarefaCompartilhadaService;
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
public class TarefaCompartilhadaController {

    private final TarefaCompartilhadaService tarefaCompartilhadaService;

    @PostMapping("/tarefas-compartilhadas")
    public ResponseEntity<TarefaCompartilhada> criar(@RequestBody TarefaCompartilhada compartilhamento) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(tarefaCompartilhadaService.criar(compartilhamento, compartilhamento.getUsuarioCriadorId()));
    }

    @GetMapping("/tarefas-compartilhadas")
    public ResponseEntity<List<TarefaCompartilhada>> listar() {
        return ResponseEntity.ok(tarefaCompartilhadaService.listar());
    }

    @GetMapping("/tarefas-compartilhadas/{id}")
    public ResponseEntity<TarefaCompartilhada> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(tarefaCompartilhadaService.buscarPorId(id));
    }

    @GetMapping("/usuarios/{id}/tarefas-compartilhadas")
    public ResponseEntity<List<TarefaCompartilhada>> listarPorUsuario(@PathVariable Long id) {
        return ResponseEntity.ok(tarefaCompartilhadaService.listarPorUsuario(id));
    }

    @GetMapping("/tarefas/{id}/compartilhamentos")
    public ResponseEntity<List<TarefaCompartilhada>> listarPorTarefa(@PathVariable Long id) {
        return ResponseEntity.ok(tarefaCompartilhadaService.listarPorTarefa(id));
    }

    @PutMapping("/tarefas-compartilhadas/{id}")
    public ResponseEntity<TarefaCompartilhada> atualizarPermissao(
            @PathVariable Long id,
            @RequestBody AlterarPermissaoRequest request) {

        return ResponseEntity.ok(
                tarefaCompartilhadaService.atualizarPermissao(
                        id,
                        request.usuarioLogadoId(),
                        request.permissao()
                )
        );
    }

    @DeleteMapping("/tarefas-compartilhadas/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        tarefaCompartilhadaService.deletar(id);
        return ResponseEntity.noContent().build();
    }

    public record AlterarPermissaoRequest(
            Long usuarioLogadoId,
            PermissaoTarefa permissao
    ) {
    }
}