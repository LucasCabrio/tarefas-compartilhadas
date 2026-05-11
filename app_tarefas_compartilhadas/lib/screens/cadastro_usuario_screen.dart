import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();

  final UsuarioService _usuarioService = UsuarioService();

  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvarUsuario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final usuario = Usuario(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
        telefone: _telefoneController.text.trim(),
      );

      await _usuarioService.criar(usuario);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário cadastrado com sucesso!'),
        ),
      );

      _nomeController.clear();
      _emailController.clear();
      _senhaController.clear();
      _telefoneController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar usuário: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Usuário'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(
                    Icons.person_add,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Novo Usuário',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _campoTexto(
                    controller: _nomeController,
                    label: 'Nome',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o nome';
                      }
                      return null;
                    },
                  ),

                  _campoTexto(
                    controller: _emailController,
                    label: 'E-mail',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o e-mail';
                      }

                      if (!value.contains('@')) {
                        return 'Informe um e-mail válido';
                      }

                      return null;
                    },
                  ),

                  _campoTexto(
                    controller: _senhaController,
                    label: 'Senha',
                    icon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a senha';
                      }

                      if (value.length < 3) {
                        return 'A senha deve ter pelo menos 3 caracteres';
                      }

                      return null;
                    },
                  ),

                  _campoTexto(
                    controller: _telefoneController,
                    label: 'Telefone',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 8),

                  FilledButton.icon(
                    onPressed: _salvando ? null : _salvarUsuario,
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _salvando ? 'Salvando...' : 'Salvar Usuário',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}