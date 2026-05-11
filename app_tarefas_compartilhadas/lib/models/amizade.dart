import 'usuario.dart';

class Amizade {
  final int? id;
  final Usuario? usuarioSolicitante;
  final Usuario? usuarioAmigo;
  final String? statusAmizade;
  final String? dataSolicitacao;

  Amizade({
    this.id,
    this.usuarioSolicitante,
    this.usuarioAmigo,
    this.statusAmizade,
    this.dataSolicitacao,
  });

  factory Amizade.fromJson(Map<String, dynamic> json) {
    return Amizade(
      id: json['id'],
      usuarioSolicitante: json['usuarioSolicitante'] != null
          ? Usuario.fromJson(json['usuarioSolicitante'])
          : null,
      usuarioAmigo: json['usuarioAmigo'] != null
          ? Usuario.fromJson(json['usuarioAmigo'])
          : null,
      statusAmizade: json['statusAmizade'],
      dataSolicitacao: json['dataSolicitacao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioSolicitante': usuarioSolicitante?.toJson(),
      'usuarioAmigo': usuarioAmigo?.toJson(),
      'statusAmizade': statusAmizade,
      'dataSolicitacao': dataSolicitacao,
    };
  }
}