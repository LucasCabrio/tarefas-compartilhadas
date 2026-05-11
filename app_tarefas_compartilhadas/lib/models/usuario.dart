class Usuario {
  final int? id;
  final String? nome;
  final String? email;
  final String? senha;
  final String? telefone;

  Usuario({
    this.id,
    this.nome,
    this.email,
    this.senha,
    this.telefone,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      senha: json['senha'],
      telefone: json['telefone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'telefone': telefone,
    };
  }
}