import '../models/usuario.dart';
import 'api_service.dart';

class UsuarioService {
  final ApiService _api = ApiService();

  Future<List<Usuario>> listar() async {
    final lista = await _api.getList('/usuarios');
    return lista.map((item) => Usuario.fromJson(item)).toList();
  }

  Future<Usuario> buscarPorId(int id) async {
    final item = await _api.getObject('/usuarios/$id');
    return Usuario.fromJson(item);
  }

  Future<Usuario> criar(Usuario usuario) async {
    final item = await _api.post('/usuarios', usuario.toJson());
    return Usuario.fromJson(item);
  }

  Future<Usuario> atualizar(int id, Usuario usuario) async {
    final item = await _api.put('/usuarios/$id', usuario.toJson());
    return Usuario.fromJson(item);
  }

  Future<void> deletar(int id) async {
    await _api.delete('/usuarios/$id');
  }
}