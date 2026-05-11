import '../models/comentario_tarefa.dart';
import 'api_service.dart';

class ComentarioTarefaService {
  final ApiService _api = ApiService();

  Future<List<ComentarioTarefa>> listar() async {
    final lista = await _api.getList('/comentarios');
    return lista.map((item) => ComentarioTarefa.fromJson(item)).toList();
  }

  Future<ComentarioTarefa> buscarPorId(int id) async {
    final item = await _api.getObject('/comentarios/$id');
    return ComentarioTarefa.fromJson(item);
  }

  Future<List<ComentarioTarefa>> listarPorTarefa(int tarefaId) async {
    final lista = await _api.getList('/tarefas/$tarefaId/comentarios');
    return lista.map((item) => ComentarioTarefa.fromJson(item)).toList();
  }

  Future<ComentarioTarefa> criar(ComentarioTarefa comentario) async {
    final item = await _api.post('/comentarios', comentario.toJson());
    return ComentarioTarefa.fromJson(item);
  }

  Future<void> deletar(int id) async {
    await _api.delete('/comentarios/$id');
  }
}