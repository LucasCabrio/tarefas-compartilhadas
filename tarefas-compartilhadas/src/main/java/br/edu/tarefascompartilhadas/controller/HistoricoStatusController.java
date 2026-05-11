package br.edu.tarefascompartilhadas.controller;

import br.edu.tarefascompartilhadas.model.HistoricoStatus;
import br.edu.tarefascompartilhadas.service.HistoricoStatusService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class HistoricoStatusController {

    private final HistoricoStatusService historicoStatusService;

    @GetMapping("/historicos-status")
    public ResponseEntity<List<HistoricoStatus>> listar() {
        return ResponseEntity.ok(historicoStatusService.listar());
    }

    @GetMapping("/historicos-status/{id}")
    public ResponseEntity<HistoricoStatus> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(historicoStatusService.buscarPorId(id));
    }

    @GetMapping("/tarefas/{id}/historico-status")
    public ResponseEntity<List<HistoricoStatus>> listarPorTarefa(@PathVariable Long id) {
        return ResponseEntity.ok(historicoStatusService.listarPorTarefa(id));
    }
}
