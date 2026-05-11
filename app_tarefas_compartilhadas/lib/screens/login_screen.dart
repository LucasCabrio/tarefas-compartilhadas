import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../utils/app_session.dart';
import 'menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  final UsuarioService _usuarioService = UsuarioService();

  bool _carregando = false;
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final usuarios = await _usuarioService.listar();

      final emailDigitado = _emailController.text.trim();
      final senhaDigitada = _senhaController.text.trim();

      Usuario? usuarioEncontrado;

      for (final usuario in usuarios) {
        if (usuario.email == emailDigitado && usuario.senha == senhaDigitada) {
          usuarioEncontrado = usuario;
          break;
        }
      }

      if (!mounted) return;

      if (usuarioEncontrado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail ou senha inválidos.'),
          ),
        );
        return;
      }

      AppSession.usuarioLogado = usuarioEncontrado;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bem-vindo, ${usuarioEncontrado.nome ?? 'usuário'}!'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MenuScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao realizar login: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _entrarSemLogin() {
    AppSession.limparSessao();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MenuScreen(),
      ),
    );
  }

  Widget _campoEmail() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'E-mail',
          prefixIcon: Icon(Icons.email),
        ),
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
    );
  }

  Widget _campoSenha() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _senhaController,
        obscureText: _ocultarSenha,
        decoration: InputDecoration(
          labelText: 'Senha',
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(
              _ocultarSenha ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _ocultarSenha = !_ocultarSenha;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Informe a senha';
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 520,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.task_alt,
                        size: 72,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tarefas Compartilhadas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entre com seu e-mail e senha para acessar o sistema.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _campoEmail(),
                      _campoSenha(),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _carregando ? null : _entrar,
                        icon: _carregando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(
                          _carregando ? 'Entrando...' : 'Entrar',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _entrarSemLogin,
                        child: const Text(
                          'Entrar sem login',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}