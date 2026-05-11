import 'tarefa.dart';
import 'usuario.dart';

class TarefaCompartilhada {
  final int? id;
  final Tarefa? tarefa;
  final Usuario? usuarioCompartilhado;
  final String? permissao;
  final String? dataCompartilhamento;
  final int? usuarioCriadorId;

  TarefaCompartilhada({
    this.id,
    this.tarefa,
    this.usuarioCompartilhado,
    this.permissao,
    this.dataCompartilhamento,
    this.usuarioCriadorId,
  });

  factory TarefaCompartilhada.fromJson(Map<String, dynamic> json) {
    return TarefaCompartilhada(
      id: json['id'],
      tarefa: json['tarefa'] != null
          ? Tarefa.fromJson(json['tarefa'])
          : null,
      usuarioCompartilhado: json['usuarioCompartilhado'] != null
          ? Usuario.fromJson(json['usuarioCompartilhado'])
          : null,
      permissao: json['permissao'],
      dataCompartilhamento: json['dataCompartilhamento'],
      usuarioCriadorId: json['usuarioCriadorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tarefa': tarefa?.toJson(),
      'usuarioCompartilhado': usuarioCompartilhado?.toJson(),
      'permissao': permissao,
      'dataCompartilhamento': dataCompartilhamento,
      'usuarioCriadorId': usuarioCriadorId,
    };
  }
}