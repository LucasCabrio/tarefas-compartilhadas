import '../models/historico_status.dart';
import 'api_service.dart';

class HistoricoStatusService {
  final ApiService _api = ApiService();

  Future<List<HistoricoStatus>> listar() async {
    final lista = await _api.getList('/historicos-status');
    return lista.map((item) => HistoricoStatus.fromJson(item)).toList();
  }

  Future<HistoricoStatus> buscarPorId(int id) async {
    final item = await _api.getObject('/historicos-status/$id');
    return HistoricoStatus.fromJson(item);
  }

  Future<List<HistoricoStatus>> listarPorTarefa(int tarefaId) async {
    final lista = await _api.getList('/tarefas/$tarefaId/historico-status');
    return lista.map((item) => HistoricoStatus.fromJson(item)).toList();
  }
}