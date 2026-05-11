import 'tarefa.dart';
import 'usuario.dart';

class ComentarioTarefa {
  final int? id;
  final Tarefa? tarefa;
  final Usuario? usuario;
  final String? texto;
  final String? dataComentario;

  ComentarioTarefa({
    this.id,
    this.tarefa,
    this.usuario,
    this.texto,
    this.dataComentario,
  });

  factory ComentarioTarefa.fromJson(Map<String, dynamic> json) {
    return ComentarioTarefa(
      id: json['id'],
      tarefa: json['tarefa'] != null
          ? Tarefa.fromJson(json['tarefa'])
          : null,
      usuario: json['usuario'] != null
          ? Usuario.fromJson(json['usuario'])
          : null,
      texto: json['texto'],
      dataComentario: json['dataComentario'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tarefa': tarefa?.toJson(),
      'usuario': usuario?.toJson(),
      'texto': texto,
      'dataComentario': dataComentario,
    };
  }
}