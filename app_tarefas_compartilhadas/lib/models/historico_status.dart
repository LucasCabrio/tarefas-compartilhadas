import 'tarefa.dart';
import 'usuario.dart';

class HistoricoStatus {
  final int? id;
  final Tarefa? tarefa;
  final Usuario? usuario;
  final String? statusAnterior;
  final String? statusNovo;
  final String? dataAlteracao;

  HistoricoStatus({
    this.id,
    this.tarefa,
    this.usuario,
    this.statusAnterior,
    this.statusNovo,
    this.dataAlteracao,
  });

  factory HistoricoStatus.fromJson(Map<String, dynamic> json) {
    return HistoricoStatus(
      id: json['id'],
      tarefa: json['tarefa'] != null
          ? Tarefa.fromJson(json['tarefa'])
          : null,
      usuario: json['usuario'] != null
          ? Usuario.fromJson(json['usuario'])
          : null,
      statusAnterior: json['statusAnterior'],
      statusNovo: json['statusNovo'],
      dataAlteracao: json['dataAlteracao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tarefa': tarefa?.toJson(),
      'usuario': usuario?.toJson(),
      'statusAnterior': statusAnterior,
      'statusNovo': statusNovo,
      'dataAlteracao': dataAlteracao,
    };
  }
}