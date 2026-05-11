import '../models/amizade.dart';
import 'api_service.dart';

class AmizadeService {
  final ApiService _api = ApiService();

  Future<List<Amizade>> listar() async {
    final lista = await _api.getList('/amizades');
    return lista.map((item) => Amizade.fromJson(item)).toList();
  }

  Future<Amizade> buscarPorId(int id) async {
    final item = await _api.getObject('/amizades/$id');
    return Amizade.fromJson(item);
  }

  Future<List<Amizade>> listarAmigos(int usuarioId) async {
    final lista = await _api.getList('/usuarios/$usuarioId/amigos');
    return lista.map((item) => Amizade.fromJson(item)).toList();
  }

  Future<List<Amizade>> listarSolicitacoes(int usuarioId) async {
    final lista = await _api.getList('/usuarios/$usuarioId/solicitacoes');
    return lista.map((item) => Amizade.fromJson(item)).toList();
  }

  Future<Amizade> criar(Amizade amizade) async {
    final item = await _api.post('/amizades', amizade.toJson());
    return Amizade.fromJson(item);
  }

  Future<Amizade> aceitar({
    required int id,
    required int usuarioLogadoId,
  }) async {
    final item = await _api.put('/amizades/$id/aceitar', {
      'usuarioLogadoId': usuarioLogadoId,
    });

    return Amizade.fromJson(item);
  }

  Future<Amizade> recusar({
    required int id,
    required int usuarioLogadoId,
  }) async {
    final item = await _api.put('/amizades/$id/recusar', {
      'usuarioLogadoId': usuarioLogadoId,
    });

    return Amizade.fromJson(item);
  }

  Future<void> deletar(int id) async {
    await _api.delete('/amizades/$id');
  }
}