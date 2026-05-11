import '../models/usuario.dart';

class AppSession {
  static Usuario? usuarioLogado;

  static bool get estaLogado {
    return usuarioLogado != null;
  }

  static int? get usuarioLogadoId {
    return usuarioLogado?.id;
  }

  static String get nomeUsuarioLogado {
    return usuarioLogado?.nome ?? 'Usuário';
  }

  static void limparSessao() {
    usuarioLogado = null;
  }
}