import '../models/tarefa.dart';
import 'api_service.dart';

class TarefaService {
  final ApiService _api = ApiService();

  Future<List<Tarefa>> listar() async {
    final lista = await _api.getList('/tarefas');
    return lista.map((item) => Tarefa.fromJson(item)).toList();
  }

  Future<Tarefa> buscarPorId(int id) async {
    final item = await _api.getObject('/tarefas/$id');
    return Tarefa.fromJson(item);
  }

  Future<List<Tarefa>> listarPorUsuario(int usuarioId) async {
    final lista = await _api.getList('/usuarios/$usuarioId/tarefas');
    return lista.map((item) => Tarefa.fromJson(item)).toList();
  }

  Future<Tarefa> criar(Tarefa tarefa) async {
    final item = await _api.post('/tarefas', tarefa.toJson());
    return Tarefa.fromJson(item);
  }

  Future<Tarefa> atualizar(int id, Tarefa tarefa) async {
    final item = await _api.put('/tarefas/$id', tarefa.toJson());
    return Tarefa.fromJson(item);
  }

  Future<Tarefa> editarDadosPrincipais({
    required int id,
    required String titulo,
    required String descricao,
    required String statusAtual,
    required String prioridade,
    required String? dataLimite,
    required int usuarioCriadorId,
    required int usuarioLogadoId,
    int? usuarioResponsavelId,
  }) async {
    final item = await _api.put('/tarefas/$id', {
      'titulo': titulo,
      'descricao': descricao,
      'statusAtual': statusAtual,
      'prioridade': prioridade,
      'dataLimite': dataLimite,
      'usuarioCriador': {
        'id': usuarioCriadorId,
      },
      'usuarioResponsavelId': usuarioResponsavelId,
      'usuarioLogadoId': usuarioLogadoId,
    });

    return Tarefa.fromJson(item);
  }

  Future<Tarefa> alterarStatus({
    required int tarefaId,
    required int usuarioId,
    required String statusNovo,
  }) async {
    final item = await _api.patch('/tarefas/$tarefaId/status', {
      'usuarioId': usuarioId,
      'statusNovo': statusNovo,
    });

    return Tarefa.fromJson(item);
  }

  Future<void> deletar(int id) async {
    await _api.delete('/tarefas/$id');
  }
}