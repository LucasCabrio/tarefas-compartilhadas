package br.edu.tarefascompartilhadas.controller;

import br.edu.tarefascompartilhadas.enums.PrioridadeTarefa;
import br.edu.tarefascompartilhadas.enums.StatusTarefa;
import br.edu.tarefascompartilhadas.model.Tarefa;
import br.edu.tarefascompartilhadas.service.TarefaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequiredArgsConstructor
public class TarefaController {

    private final TarefaService tarefaService;

    @PostMapping("/tarefas")
    public ResponseEntity<Tarefa> criar(@RequestBody Tarefa tarefa) {
        return ResponseEntity.status(HttpStatus.CREATED).body(tarefaService.criar(tarefa));
    }

    @GetMapping("/tarefas")
    public ResponseEntity<List<Tarefa>> listar() {
        return ResponseEntity.ok(tarefaService.listar());
    }

    @GetMapping("/tarefas/{id}")
    public ResponseEntity<Tarefa> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(tarefaService.buscarPorId(id));
    }

    @PutMapping("/tarefas/{id}")
    public ResponseEntity<Tarefa> atualizar(
            @PathVariable Long id,
            @RequestBody AtualizarTarefaRequest request) {

        return ResponseEntity.ok(
                tarefaService.atualizar(
                        id,
                        request.usuarioLogadoId(),
                        request.titulo(),
                        request.descricao(),
                        request.statusAtual(),
                        request.prioridade(),
                        request.dataLimite(),
                        request.usuarioResponsavelId()
                )
        );
    }

    @PatchMapping("/tarefas/{id}/status")
    public ResponseEntity<Tarefa> alterarStatus(
            @PathVariable Long id,
            @RequestBody AlterarStatusRequest request) {

        return ResponseEntity.ok(
                tarefaService.alterarStatus(
                        id,
                        request.usuarioId(),
                        request.statusNovo()
                )
        );
    }

    @DeleteMapping("/tarefas/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        tarefaService.deletar(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/usuarios/{id}/tarefas")
    public ResponseEntity<List<Tarefa>> listarPorUsuario(@PathVariable Long id) {
        return ResponseEntity.ok(tarefaService.listarPorUsuario(id));
    }

    public record AlterarStatusRequest(
            Long usuarioId,
            StatusTarefa statusNovo
    ) {
    }

    public record AtualizarTarefaRequest(
            String titulo,
            String descricao,
            StatusTarefa statusAtual,
            PrioridadeTarefa prioridade,
            LocalDateTime dataLimite,
            Long usuarioResponsavelId,
            Long usuarioLogadoId
    ) {
    }
}