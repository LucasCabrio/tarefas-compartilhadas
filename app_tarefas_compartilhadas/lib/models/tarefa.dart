import 'usuario.dart';

class Tarefa {
  final int? id;
  final String? titulo;
  final String? descricao;
  final String? statusAtual;
  final String? prioridade;
  final String? dataCriacao;
  final String? dataLimite;
  final Usuario? usuarioCriador;
  final int? usuarioResponsavelId;

  Tarefa({
    this.id,
    this.titulo,
    this.descricao,
    this.statusAtual,
    this.prioridade,
    this.dataCriacao,
    this.dataLimite,
    this.usuarioCriador,
    this.usuarioResponsavelId,
  });

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      statusAtual: json['statusAtual'],
      prioridade: json['prioridade'],
      dataCriacao: json['dataCriacao'],
      dataLimite: json['dataLimite'],
      usuarioCriador: json['usuarioCriador'] != null
          ? Usuario.fromJson(json['usuarioCriador'])
          : null,
      usuarioResponsavelId: json['usuarioResponsavelId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'statusAtual': statusAtual,
      'prioridade': prioridade,
      'dataCriacao': dataCriacao,
      'dataLimite': dataLimite,
      'usuarioCriador': usuarioCriador?.toJson(),
      'usuarioResponsavelId': usuarioResponsavelId,
    };
  }
}