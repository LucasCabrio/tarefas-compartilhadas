import 'package:flutter/material.dart';

import '../models/comentario_tarefa.dart';
import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/comentario_tarefa_service.dart';
import '../services/usuario_service.dart';

class ComentariosScreen extends StatefulWidget {
  final Tarefa tarefa;

  const ComentariosScreen({
    super.key,
    required this.tarefa,
  });

  @override
  State<ComentariosScreen> createState() => _ComentariosScreenState();
}

class _ComentariosScreenState extends State<ComentariosScreen> {
  final ComentarioTarefaService _comentarioService = ComentarioTarefaService();
  final UsuarioService _usuarioService = UsuarioService();

  final _comentarioController = TextEditingController();

  late Future<List<ComentarioTarefa>> _comentariosFuture;

  List<Usuario> _usuarios = [];
  Usuario? _usuarioSelecionado;

  bool _carregandoUsuarios = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarComentarios();
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  void _carregarComentarios() {
    if (widget.tarefa.id != null) {
      _comentariosFuture =
          _comentarioService.listarPorTarefa(widget.tarefa.id!);
    } else {
      _comentariosFuture = Future.value([]);
    }
  }

  Future<void> _atualizarComentarios() async {
    setState(() {
      _carregarComentarios();
    });
  }

  Future<void> _carregarUsuarios() async {
    try {
      final usuarios = await _usuarioService.listar();

      if (!mounted) return;

      setState(() {
        _usuarios = usuarios;
        _usuarioSelecionado = usuarios.isNotEmpty ? usuarios.first : null;
        _carregandoUsuarios = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregandoUsuarios = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar usuários: $e'),
        ),
      );
    }
  }

  String _formatarData(String? data) {
    if (data == null || data.isEmpty) {
      return '-';
    }

    try {
      final dateTime = DateTime.parse(data);

      final dia = dateTime.day.toString().padLeft(2, '0');
      final mes = dateTime.month.toString().padLeft(2, '0');
      final ano = dateTime.year.toString();
      final hora = dateTime.hour.toString().padLeft(2, '0');
      final minuto = dateTime.minute.toString().padLeft(2, '0');

      return '$dia/$mes/$ano às $hora:$minuto';
    } catch (e) {
      return data;
    }
  }

  Future<void> _salvarComentario() async {
    final texto = _comentarioController.text.trim();

    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um comentário antes de salvar.'),
        ),
      );
      return;
    }

    if (widget.tarefa.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarefa inválida para comentário.'),
        ),
      );
      return;
    }

    if (_usuarioSelecionado == null || _usuarioSelecionado!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um usuário para comentar.'),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final comentario = ComentarioTarefa(
        tarefa: Tarefa(
          id: widget.tarefa.id,
        ),
        usuario: Usuario(
          id: _usuarioSelecionado!.id,
        ),
        texto: texto,
      );

      await _comentarioService.criar(comentario);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentário salvo com sucesso!'),
        ),
      );

      _comentarioController.clear();

      setState(() {
        _carregarComentarios();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar comentário: $e'),
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

  Future<void> _excluirComentario(int id) async {
    try {
      await _comentarioService.deletar(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentário excluído com sucesso!'),
        ),
      );

      setState(() {
        _carregarComentarios();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir comentário: $e'),
        ),
      );
    }
  }

  void _confirmarExclusao(ComentarioTarefa comentario) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text(
            'Deseja realmente excluir este comentário?',
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

                if (comentario.id != null) {
                  _excluirComentario(comentario.id!);
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Widget _formComentario() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Novo Comentário',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            if (_carregandoUsuarios)
              const CircularProgressIndicator()
            else if (_usuarios.isEmpty)
              const Text(
                'Nenhum usuário cadastrado. Cadastre um usuário antes de comentar.',
                style: TextStyle(color: Colors.red),
              )
            else
              DropdownButtonFormField<Usuario>(
                initialValue: _usuarioSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                  prefixIcon: Icon(Icons.person),
                ),
                items: _usuarios.map((usuario) {
                  return DropdownMenuItem<Usuario>(
                    value: usuario,
                    child: Text('${usuario.id} - ${usuario.nome ?? 'Sem nome'}'),
                  );
                }).toList(),
                onChanged: (usuario) {
                  setState(() {
                    _usuarioSelecionado = usuario;
                  });
                },
              ),

            const SizedBox(height: 16),

            TextField(
              controller: _comentarioController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Comentário',
                prefixIcon: Icon(Icons.comment),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: _salvando ? null : _salvarComentario,
              icon: _salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _salvando ? 'Salvando...' : 'Salvar Comentário',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardComentario(ComentarioTarefa comentario) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            comentario.id?.toString() ?? '?',
          ),
        ),
        title: Text(
          comentario.usuario?.nome ?? 'Usuário não informado',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comentario.texto ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Data: ${_formatarData(comentario.dataComentario)}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _confirmarExclusao(comentario);
          },
        ),
      ),
    );
  }

  Widget _listaComentarios(List<ComentarioTarefa> comentarios) {
    if (comentarios.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Nenhum comentário cadastrado para esta tarefa.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Column(
      children: comentarios.map((comentario) {
        return _cardComentario(comentario);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentários'),
        actions: [
          IconButton(
            onPressed: _atualizarComentarios,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _atualizarComentarios,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.task_alt,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.tarefa.titulo ?? 'Tarefa sem título',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.tarefa.descricao ?? '',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _formComentario(),

            const SizedBox(height: 16),

            const Text(
              'Comentários da Tarefa',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            FutureBuilder<List<ComentarioTarefa>>(
              future: _comentariosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Erro ao carregar comentários:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final comentarios = snapshot.data ?? [];

                return _listaComentarios(comentarios);
              },
            ),
          ],
        ),
      ),
    );
  }
}