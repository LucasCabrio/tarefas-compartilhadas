import '../models/tarefa_compartilhada.dart';
import 'api_service.dart';

class TarefaCompartilhadaService {
  final ApiService _api = ApiService();

  Future<List<TarefaCompartilhada>> listar() async {
    final lista = await _api.getList('/tarefas-compartilhadas');
    return lista.map((item) => TarefaCompartilhada.fromJson(item)).toList();
  }

  Future<TarefaCompartilhada> buscarPorId(int id) async {
    final item = await _api.getObject('/tarefas-compartilhadas/$id');
    return TarefaCompartilhada.fromJson(item);
  }

  Future<List<TarefaCompartilhada>> listarPorUsuario(int usuarioId) async {
    final lista = await _api.getList(
      '/usuarios/$usuarioId/tarefas-compartilhadas',
    );

    return lista.map((item) => TarefaCompartilhada.fromJson(item)).toList();
  }

  Future<List<TarefaCompartilhada>> listarPorTarefa(int tarefaId) async {
    final lista = await _api.getList('/tarefas/$tarefaId/compartilhamentos');
    return lista.map((item) => TarefaCompartilhada.fromJson(item)).toList();
  }

  Future<TarefaCompartilhada> criar(
    TarefaCompartilhada compartilhamento,
  ) async {
    final item = await _api.post(
      '/tarefas-compartilhadas',
      compartilhamento.toJson(),
    );

    return TarefaCompartilhada.fromJson(item);
  }

  Future<TarefaCompartilhada> atualizarPermissao({
    required int id,
    required int usuarioLogadoId,
    required String permissao,
  }) async {
    final item = await _api.put('/tarefas-compartilhadas/$id', {
      'usuarioLogadoId': usuarioLogadoId,
      'permissao': permissao,
    });

    return TarefaCompartilhada.fromJson(item);
  }

  Future<void> deletar(int id) async {
    await _api.delete('/tarefas-compartilhadas/$id');
  }
}