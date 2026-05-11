import 'package:flutter/material.dart';

import '../models/amizade.dart';
import '../models/usuario.dart';
import '../services/amizade_service.dart';
import '../services/usuario_service.dart';
import '../utils/app_session.dart';

class AmigosScreen extends StatefulWidget {
  const AmigosScreen({super.key});

  @override
  State<AmigosScreen> createState() => _AmigosScreenState();
}

class _AmigosScreenState extends State<AmigosScreen> {
  final AmizadeService _amizadeService = AmizadeService();
  final UsuarioService _usuarioService = UsuarioService();

  Future<List<Amizade>> _amizadesFuture = Future.value([]);

  List<Usuario> _usuarios = [];

  Usuario? _usuarioSolicitante;
  Usuario? _usuarioAmigo;

  bool _carregandoUsuarios = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarAmizades();
    _carregarUsuarios();
  }

  void _carregarAmizades() {
    _amizadesFuture = _amizadeService.listar();
  }

  Future<void> _atualizarTela() async {
    setState(() {
      _carregarAmizades();
    });
  }

  Future<void> _carregarUsuarios() async {
    try {
      final usuarios = await _usuarioService.listar();

      if (!mounted) return;

      setState(() {
        _usuarios = usuarios;

        if (AppSession.usuarioLogado != null) {
          _usuarioSolicitante = usuarios.firstWhere(
            (usuario) => usuario.id == AppSession.usuarioLogadoId,
            orElse: () => usuarios.isNotEmpty ? usuarios.first : AppSession.usuarioLogado!,
          );
        } else if (usuarios.isNotEmpty) {
          _usuarioSolicitante = usuarios.first;
        }

        if (usuarios.length > 1) {
          _usuarioAmigo = usuarios.firstWhere(
            (usuario) => usuario.id != _usuarioSolicitante?.id,
            orElse: () => usuarios.first,
          );
        } else if (usuarios.isNotEmpty) {
          _usuarioAmigo = usuarios.first;
        }

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

  Color _corStatus(String? status) {
    switch (status) {
      case 'PENDENTE':
        return Colors.orange;
      case 'ACEITA':
        return Colors.green;
      case 'RECUSADA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _etiquetaStatus(String? status) {
    final cor = _corStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: cor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor),
      ),
      child: Text(
        status ?? '-',
        style: TextStyle(
          color: cor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  bool _usuarioLogadoEhDestinatario(Amizade amizade) {
    final usuarioLogadoId = AppSession.usuarioLogadoId;
    final amigoId = amizade.usuarioAmigo?.id;

    if (usuarioLogadoId == null || amigoId == null) {
      return false;
    }

    return usuarioLogadoId == amigoId;
  }

  bool _usuarioLogadoEhSolicitante(Amizade amizade) {
    final usuarioLogadoId = AppSession.usuarioLogadoId;
    final solicitanteId = amizade.usuarioSolicitante?.id;

    if (usuarioLogadoId == null || solicitanteId == null) {
      return false;
    }

    return usuarioLogadoId == solicitanteId;
  }

  Future<void> _enviarSolicitacao() async {
    if (_usuarioSolicitante == null || _usuarioAmigo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione os dois usuários.'),
        ),
      );
      return;
    }

    if (_usuarioSolicitante!.id == _usuarioAmigo!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O usuário solicitante e o amigo não podem ser iguais.'),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final amizade = Amizade(
        usuarioSolicitante: Usuario(
          id: _usuarioSolicitante!.id,
        ),
        usuarioAmigo: Usuario(
          id: _usuarioAmigo!.id,
        ),
        statusAmizade: 'PENDENTE',
      );

      await _amizadeService.criar(amizade);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação de amizade enviada com sucesso!'),
        ),
      );

      setState(() {
        _carregarAmizades();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar solicitação: $e'),
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

  Future<void> _aceitarAmizade(int id) async {
    final usuarioLogadoId = AppSession.usuarioLogadoId;

    if (usuarioLogadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login para responder a solicitação.'),
        ),
      );
      return;
    }

    try {
      await _amizadeService.aceitar(
        id: id,
        usuarioLogadoId: usuarioLogadoId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amizade aceita com sucesso!'),
        ),
      );

      setState(() {
        _carregarAmizades();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao aceitar amizade: $e'),
        ),
      );
    }
  }

  Future<void> _recusarAmizade(int id) async {
    final usuarioLogadoId = AppSession.usuarioLogadoId;

    if (usuarioLogadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login para responder a solicitação.'),
        ),
      );
      return;
    }

    try {
      await _amizadeService.recusar(
        id: id,
        usuarioLogadoId: usuarioLogadoId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amizade recusada com sucesso!'),
        ),
      );

      setState(() {
        _carregarAmizades();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao recusar amizade: $e'),
        ),
      );
    }
  }

  Future<void> _excluirAmizade(int id) async {
    try {
      await _amizadeService.deletar(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amizade excluída com sucesso!'),
        ),
      );

      setState(() {
        _carregarAmizades();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir amizade: $e'),
        ),
      );
    }
  }

  void _confirmarExclusao(Amizade amizade) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text(
            'Deseja realmente excluir esta amizade?',
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

                if (amizade.id != null) {
                  _excluirAmizade(amizade.id!);
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Widget _dropdownUsuario({
    required String label,
    required Usuario? value,
    required void Function(Usuario?) onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<Usuario>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.person),
        ),
        items: _usuarios.map((usuario) {
          return DropdownMenuItem<Usuario>(
            value: usuario,
            child: Text('${usuario.id} - ${usuario.nome ?? 'Sem nome'}'),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  Widget _formSolicitacao() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Nova Solicitação de Amizade',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (AppSession.estaLogado)
              Text(
                'Usuário logado: ${AppSession.nomeUsuarioLogado}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              const Text(
                'Nenhum usuário está logado. Faça login para controlar corretamente as solicitações.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),

            const SizedBox(height: 20),

            if (_carregandoUsuarios)
              const CircularProgressIndicator()
            else if (_usuarios.length < 2)
              const Text(
                'Cadastre pelo menos dois usuários para criar uma amizade.',
                style: TextStyle(color: Colors.red),
              )
            else ...[
              _dropdownUsuario(
                label: 'Usuário solicitante',
                value: _usuarioSolicitante,
                enabled: !AppSession.estaLogado,
                onChanged: (usuario) {
                  setState(() {
                    _usuarioSolicitante = usuario;
                  });
                },
              ),

              _dropdownUsuario(
                label: 'Usuário amigo',
                value: _usuarioAmigo,
                onChanged: (usuario) {
                  setState(() {
                    _usuarioAmigo = usuario;
                  });
                },
              ),

              FilledButton.icon(
                onPressed: _salvando ? null : _enviarSolicitacao,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add),
                label: Text(
                  _salvando ? 'Enviando...' : 'Enviar Solicitação',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _mensagemRespostaSolicitacao(Amizade amizade) {
    if (amizade.statusAmizade != 'PENDENTE') {
      return const SizedBox.shrink();
    }

    final nomeAmigo = amizade.usuarioAmigo?.nome ?? 'usuário';
    final nomeSolicitante = amizade.usuarioSolicitante?.nome ?? 'solicitante';

    if (_usuarioLogadoEhDestinatario(amizade)) {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: amizade.id == null
                  ? null
                  : () {
                      _aceitarAmizade(amizade.id!);
                    },
              icon: const Icon(Icons.check),
              label: const Text('Aceitar'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: amizade.id == null
                  ? null
                  : () {
                      _recusarAmizade(amizade.id!);
                    },
              icon: const Icon(Icons.close),
              label: const Text('Recusar'),
            ),
          ),
        ],
      );
    }

    if (_usuarioLogadoEhSolicitante(amizade)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange),
        ),
        child: Text(
          'Aguardando resposta de $nomeAmigo.',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Text(
        'Você não pode responder esta solicitação. Apenas $nomeAmigo pode aceitar ou recusar o pedido enviado por $nomeSolicitante.',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _cardAmizade(Amizade amizade) {
    final status = amizade.statusAmizade;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    amizade.id?.toString() ?? '?',
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Solicitação de Amizade',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _confirmarExclusao(amizade);
                  },
                ),
              ],
            ),

            const SizedBox(height: 14),

            _etiquetaStatus(status),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Solicitante: ${amizade.usuarioSolicitante?.nome ?? '-'}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.group, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Destinatário: ${amizade.usuarioAmigo?.nome ?? '-'}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data da solicitação: ${_formatarData(amizade.dataSolicitacao)}',
                  ),
                ),
              ],
            ),

            if (status == 'PENDENTE') ...[
              const SizedBox(height: 16),
              _mensagemRespostaSolicitacao(amizade),
            ],
          ],
        ),
      ),
    );
  }

  Widget _listaAmizades(List<Amizade> amizades) {
    if (amizades.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Nenhuma amizade cadastrada.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Column(
      children: amizades.map((amizade) {
        return _cardAmizade(amizade);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amigos'),
        actions: [
          IconButton(
            onPressed: _atualizarTela,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _atualizarTela,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _formSolicitacao(),

            const SizedBox(height: 20),

            const Text(
              'Amizades e Solicitações',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            FutureBuilder<List<Amizade>>(
              future: _amizadesFuture,
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
                        'Erro ao carregar amizades:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final amizades = snapshot.data ?? [];

                return _listaAmizades(amizades);
              },
            ),
          ],
        ),
      ),
    );
  }
}