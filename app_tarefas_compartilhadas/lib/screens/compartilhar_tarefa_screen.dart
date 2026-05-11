import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../models/tarefa_compartilhada.dart';
import '../models/usuario.dart';
import '../services/tarefa_compartilhada_service.dart';
import '../services/tarefa_service.dart';
import '../services/usuario_service.dart';
import '../utils/app_session.dart';
import 'detalhe_tarefa_screen.dart';

class CompartilharTarefaScreen extends StatefulWidget {
  final Tarefa? tarefaInicial;

  const CompartilharTarefaScreen({
    super.key,
    this.tarefaInicial,
  });

  @override
  State<CompartilharTarefaScreen> createState() =>
      _CompartilharTarefaScreenState();
}

class _CompartilharTarefaScreenState extends State<CompartilharTarefaScreen> {
  final TarefaService _tarefaService = TarefaService();
  final UsuarioService _usuarioService = UsuarioService();
  final TarefaCompartilhadaService _compartilhadaService =
      TarefaCompartilhadaService();

  Future<List<TarefaCompartilhada>> _compartilhamentosFuture =
      Future.value([]);

  List<Tarefa> _tarefas = [];
  List<Usuario> _usuarios = [];

  Tarefa? _tarefaSelecionada;
  Usuario? _usuarioSelecionado;

  String _permissaoSelecionada = 'VISUALIZAR';

  bool _carregandoDados = true;
  bool _salvando = false;

  final List<String> _permissoes = [
    'VISUALIZAR',
    'EDITAR_STATUS',
    'EDITAR_TAREFA',
  ];

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  Future<void> _carregarTudo() async {
    setState(() {
      _carregandoDados = true;
      _compartilhamentosFuture = Future.value([]);
    });

    try {
      final tarefas = await _tarefaService.listar();
      final usuarios = await _usuarioService.listar();
      final compartilhamentos = _compartilhadaService.listar();

      if (!mounted) return;

      setState(() {
        _tarefas = tarefas;
        _usuarios = usuarios;

        if (widget.tarefaInicial != null && widget.tarefaInicial!.id != null) {
          _tarefaSelecionada = tarefas.firstWhere(
            (tarefa) => tarefa.id == widget.tarefaInicial!.id,
            orElse: () =>
                tarefas.isNotEmpty ? tarefas.first : widget.tarefaInicial!,
          );
        } else {
          _tarefaSelecionada = tarefas.isNotEmpty ? tarefas.first : null;
        }

        if (usuarios.length > 1) {
          _usuarioSelecionado = usuarios[1];
        } else if (usuarios.isNotEmpty) {
          _usuarioSelecionado = usuarios.first;
        } else {
          _usuarioSelecionado = null;
        }

        _compartilhamentosFuture = compartilhamentos;
        _carregandoDados = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _compartilhamentosFuture = Future.value([]);
        _carregandoDados = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $e'),
        ),
      );
    }
  }

  Future<void> _atualizarTela() async {
    setState(() {
      _compartilhamentosFuture = _compartilhadaService.listar();
    });
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

  Color _corPermissao(String? permissao) {
    switch (permissao) {
      case 'VISUALIZAR':
        return Colors.blue;
      case 'EDITAR_STATUS':
        return Colors.orange;
      case 'EDITAR_TAREFA':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _nomeCriadorDaTarefa(TarefaCompartilhada compartilhamento) {
    return compartilhamento.tarefa?.usuarioCriador?.nome ?? 'Não informado';
  }

  bool _usuarioLogadoEhCriador(TarefaCompartilhada compartilhamento) {
    final usuarioLogadoId = AppSession.usuarioLogadoId;
    final criadorId = compartilhamento.tarefa?.usuarioCriador?.id;

    if (usuarioLogadoId == null || criadorId == null) {
      return false;
    }

    return usuarioLogadoId == criadorId;
  }

  Widget _etiquetaPermissao(String? permissao) {
    final cor = _corPermissao(permissao);

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
        permissao ?? '-',
        style: TextStyle(
          color: cor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _salvarCompartilhamento() async {
    if (_tarefaSelecionada == null || _tarefaSelecionada!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma tarefa.'),
        ),
      );
      return;
    }

    if (_usuarioSelecionado == null || _usuarioSelecionado!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o usuário que receberá a tarefa.'),
        ),
      );
      return;
    }

    if (_tarefaSelecionada!.usuarioCriador?.id == _usuarioSelecionado!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A tarefa não precisa ser compartilhada com o próprio criador.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final compartilhamento = TarefaCompartilhada(
        tarefa: Tarefa(
          id: _tarefaSelecionada!.id,
        ),
        usuarioCompartilhado: Usuario(
          id: _usuarioSelecionado!.id,
        ),
        permissao: _permissaoSelecionada,
        usuarioCriadorId: _tarefaSelecionada!.usuarioCriador?.id,
      );

      await _compartilhadaService.criar(compartilhamento);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarefa compartilhada com sucesso!'),
        ),
      );

      setState(() {
        _compartilhamentosFuture = _compartilhadaService.listar();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao compartilhar tarefa: $e'),
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

  Future<void> _alterarPermissaoCompartilhamento(
    TarefaCompartilhada compartilhamento,
    String novaPermissao,
  ) async {
    final usuarioLogadoId = AppSession.usuarioLogadoId;

    if (usuarioLogadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login para alterar a permissão.'),
        ),
      );
      return;
    }

    if (compartilhamento.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compartilhamento inválido.'),
        ),
      );
      return;
    }

    try {
      await _compartilhadaService.atualizarPermissao(
        id: compartilhamento.id!,
        usuarioLogadoId: usuarioLogadoId,
        permissao: novaPermissao,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissão alterada com sucesso!'),
        ),
      );

      setState(() {
        _compartilhamentosFuture = _compartilhadaService.listar();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar permissão: $e'),
        ),
      );
    }
  }

  void _abrirDialogAlterarPermissao(TarefaCompartilhada compartilhamento) {
    String permissaoSelecionada = compartilhamento.permissao ?? 'VISUALIZAR';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar Permissão'),
          content: DropdownButtonFormField<String>(
            initialValue: permissaoSelecionada,
            decoration: const InputDecoration(
              labelText: 'Nova permissão',
              prefixIcon: Icon(Icons.lock_open),
            ),
            items: _permissoes.map((permissao) {
              return DropdownMenuItem<String>(
                value: permissao,
                child: Text(permissao),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                permissaoSelecionada = value;
              }
            },
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

                _alterarPermissaoCompartilhamento(
                  compartilhamento,
                  permissaoSelecionada,
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _excluirCompartilhamento(int id) async {
    try {
      await _compartilhadaService.deletar(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compartilhamento excluído com sucesso!'),
        ),
      );

      setState(() {
        _compartilhamentosFuture = _compartilhadaService.listar();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir compartilhamento: $e'),
        ),
      );
    }
  }

  void _confirmarExclusao(TarefaCompartilhada compartilhamento) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text(
            'Deseja realmente excluir este compartilhamento?',
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

                if (compartilhamento.id != null) {
                  _excluirCompartilhamento(compartilhamento.id!);
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _abrirDetalhesCompartilhamento(
    TarefaCompartilhada compartilhamento,
  ) {
    if (compartilhamento.tarefa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta tarefa compartilhada não possui dados da tarefa.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalheTarefaScreen(
          tarefa: compartilhamento.tarefa!,
          permissaoCompartilhamento: compartilhamento.permissao,
        ),
      ),
    );
  }

  Widget _formCompartilhamento() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Novo Compartilhamento',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (_carregandoDados)
              const CircularProgressIndicator()
            else if (_tarefas.isEmpty)
              const Text(
                'Nenhuma tarefa cadastrada. Cadastre uma tarefa antes de compartilhar.',
                style: TextStyle(color: Colors.red),
              )
            else if (_usuarios.length < 2)
              const Text(
                'Cadastre pelo menos dois usuários para compartilhar uma tarefa.',
                style: TextStyle(color: Colors.red),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<Tarefa>(
                  initialValue: _tarefaSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Tarefa',
                    prefixIcon: Icon(Icons.task_alt),
                  ),
                  items: _tarefas.map((tarefa) {
                    return DropdownMenuItem<Tarefa>(
                      value: tarefa,
                      child: Text(
                        '${tarefa.id} - ${tarefa.titulo ?? 'Sem título'}',
                      ),
                    );
                  }).toList(),
                  onChanged: (tarefa) {
                    setState(() {
                      _tarefaSelecionada = tarefa;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<Usuario>(
                  initialValue: _usuarioSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Compartilhar com',
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: _usuarios.map((usuario) {
                    return DropdownMenuItem<Usuario>(
                      value: usuario,
                      child: Text(
                        '${usuario.id} - ${usuario.nome ?? 'Sem nome'}',
                      ),
                    );
                  }).toList(),
                  onChanged: (usuario) {
                    setState(() {
                      _usuarioSelecionado = usuario;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  initialValue: _permissaoSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Permissão',
                    prefixIcon: Icon(Icons.lock_open),
                  ),
                  items: _permissoes.map((permissao) {
                    return DropdownMenuItem<String>(
                      value: permissao,
                      child: Text(permissao),
                    );
                  }).toList(),
                  onChanged: (permissao) {
                    if (permissao != null) {
                      setState(() {
                        _permissaoSelecionada = permissao;
                      });
                    }
                  },
                ),
              ),
              FilledButton.icon(
                onPressed: _salvando ? null : _salvarCompartilhamento,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share),
                label: Text(
                  _salvando ? 'Compartilhando...' : 'Compartilhar Tarefa',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cardCompartilhamento(TarefaCompartilhada compartilhamento) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        _abrirDetalhesCompartilhamento(compartilhamento);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      compartilhamento.id?.toString() ?? '?',
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tarefa Compartilhada',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _confirmarExclusao(compartilhamento);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _etiquetaPermissao(compartilhamento.permissao),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.task_alt, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tarefa: ${compartilhamento.tarefa?.titulo ?? '-'}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Compartilhada com: ${compartilhamento.usuarioCompartilhado?.nome ?? 'Não informado'}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.badge, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Criador da tarefa: ${_nomeCriadorDaTarefa(compartilhamento)}',
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
                      'Compartilhada em: ${_formatarData(compartilhamento.dataCompartilhamento)}',
                    ),
                  ),
                ],
              ),
              if (_usuarioLogadoEhCriador(compartilhamento)) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    _abrirDialogAlterarPermissao(compartilhamento);
                  },
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Alterar Permissão'),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                'Toque no cartão para abrir com a permissão acima.',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listaCompartilhamentos(
    List<TarefaCompartilhada> compartilhamentos,
  ) {
    if (compartilhamentos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Nenhuma tarefa compartilhada cadastrada.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Column(
      children: compartilhamentos.map((compartilhamento) {
        return _cardCompartilhamento(compartilhamento);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compartilhar Tarefa'),
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
            _formCompartilhamento(),
            const SizedBox(height: 20),
            const Text(
              'Tarefas Compartilhadas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<TarefaCompartilhada>>(
              future: _compartilhamentosFuture,
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
                        'Erro ao carregar compartilhamentos:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final compartilhamentos = snapshot.data ?? [];

                return _listaCompartilhamentos(compartilhamentos);
              },
            ),
          ],
        ),
      ),
    );
  }
}