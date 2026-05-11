package br.edu.tarefascompartilhadas.controller;

import br.edu.tarefascompartilhadas.model.ComentarioTarefa;
import br.edu.tarefascompartilhadas.service.ComentarioTarefaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class ComentarioTarefaController {

    private final ComentarioTarefaService comentarioTarefaService;

    @PostMapping("/comentarios")
    public ResponseEntity<ComentarioTarefa> criar(@RequestBody ComentarioTarefa comentario) {
        return ResponseEntity.status(HttpStatus.CREATED).body(comentarioTarefaService.criar(comentario));
    }

    @GetMapping("/comentarios")
    public ResponseEntity<List<ComentarioTarefa>> listar() {
        return ResponseEntity.ok(comentarioTarefaService.listar());
    }

    @GetMapping("/comentarios/{id}")
    public ResponseEntity<ComentarioTarefa> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(comentarioTarefaService.buscarPorId(id));
    }

    @GetMapping("/tarefas/{id}/comentarios")
    public ResponseEntity<List<ComentarioTarefa>> listarPorTarefa(@PathVariable Long id) {
        return ResponseEntity.ok(comentarioTarefaService.listarPorTarefa(id));
    }

    @DeleteMapping("/comentarios/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        comentarioTarefaService.deletar(id);
        return ResponseEntity.noContent().build();
    }
}
