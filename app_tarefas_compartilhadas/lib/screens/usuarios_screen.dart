import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final UsuarioService _usuarioService = UsuarioService();

  late Future<List<Usuario>> _usuariosFuture;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  void _carregarUsuarios() {
    _usuariosFuture = _usuarioService.listar();
  }

  Future<void> _atualizarLista() async {
    setState(() {
      _carregarUsuarios();
    });
  }

  Future<void> _excluirUsuario(int id) async {
    try {
      await _usuarioService.deletar(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário excluído com sucesso!'),
        ),
      );

      _atualizarLista();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir usuário: $e'),
        ),
      );
    }
  }

  void _confirmarExclusao(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text(
            'Deseja realmente excluir o usuário ${usuario.nome ?? ''}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                if (usuario.id != null) {
                  _excluirUsuario(usuario.id!);
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Widget _cardUsuario(Usuario usuario) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            usuario.id?.toString() ?? '?',
          ),
        ),
        title: Text(
          usuario.nome ?? 'Sem nome',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('E-mail: ${usuario.email ?? '-'}'),
              Text('Telefone: ${usuario.telefone ?? '-'}'),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _confirmarExclusao(usuario);
          },
        ),
      ),
    );
  }

  Widget _conteudoLista(List<Usuario> usuarios) {
    if (usuarios.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum usuário cadastrado.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _atualizarLista,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          final usuario = usuarios[index];
          return _cardUsuario(usuario);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários Cadastrados'),
        actions: [
          IconButton(
            onPressed: _atualizarLista,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Erro ao carregar usuários:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final usuarios = snapshot.data ?? [];

          return _conteudoLista(usuarios);
        },
      ),
    );
  }
}