import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/tarefa_service.dart';
import '../services/usuario_service.dart';
import '../utils/app_session.dart';
import 'comentarios_screen.dart';
import 'compartilhar_tarefa_screen.dart';
import 'editar_tarefa_screen.dart';
import 'historico_status_screen.dart';

class DetalheTarefaScreen extends StatefulWidget {
  final Tarefa tarefa;
  final String? permissaoCompartilhamento;

  const DetalheTarefaScreen({
    super.key,
    required this.tarefa,
    this.permissaoCompartilhamento,
  });

  @override
  State<DetalheTarefaScreen> createState() => _DetalheTarefaScreenState();
}

class _DetalheTarefaScreenState extends State<DetalheTarefaScreen> {
  final TarefaService _tarefaService = TarefaService();
  final UsuarioService _usuarioService = UsuarioService();

  late Tarefa _tarefaAtual;

  List<Usuario> _usuarios = [];

  bool _alterandoStatus = false;

  final List<String> _statusTarefa = [
    'PENDENTE',
    'EM_ANDAMENTO',
    'CONCLUIDA',
    'CANCELADA',
  ];

  bool get _acessoNormal {
    return widget.permissaoCompartilhamento == null;
  }

  bool get _podeAlterarStatus {
    return _acessoNormal ||
        widget.permissaoCompartilhamento == 'EDITAR_STATUS' ||
        widget.permissaoCompartilhamento == 'EDITAR_TAREFA';
  }

  bool get _podeEditarTarefa {
    return _acessoNormal || widget.permissaoCompartilhamento == 'EDITAR_TAREFA';
  }

  bool get _podeCompartilhar {
    return _acessoNormal;
  }

  String get _textoPermissao {
    if (_acessoNormal) {
      return 'Dono/Criador da tarefa';
    }

    return widget.permissaoCompartilhamento ?? 'VISUALIZAR';
  }

  String get _responsavelTexto {
    final responsavelId = _tarefaAtual.usuarioResponsavelId;

    if (responsavelId == null) {
      return 'Não definido';
    }

    for (final usuario in _usuarios) {
      if (usuario.id == responsavelId) {
        return usuario.nome ?? 'Usuário ID $responsavelId';
      }
    }

    return 'Usuário ID $responsavelId';
  }

  @override
  void initState() {
    super.initState();
    _tarefaAtual = widget.tarefa;
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    try {
      final usuarios = await _usuarioService.listar();

      if (!mounted) return;

      setState(() {
        _usuarios = usuarios;
      });
    } catch (e) {
      if (!mounted) return;

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

      return '$dia/$mes/$ano';
    } catch (e) {
      return data;
    }
  }

  Color _corPrioridade(String? prioridade) {
    switch (prioridade) {
      case 'BAIXA':
        return Colors.green;
      case 'MEDIA':
        return Colors.blue;
      case 'ALTA':
        return Colors.orange;
      case 'URGENTE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _corStatus(String? status) {
    switch (status) {
      case 'PENDENTE':
        return Colors.orange;
      case 'EM_ANDAMENTO':
        return Colors.blue;
      case 'CONCLUIDA':
        return Colors.green;
      case 'CANCELADA':
        return Colors.red;
      default:
        return Colors.grey;
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

  Widget _etiqueta({
    required String texto,
    required Color cor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: cor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: cor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _linhaInfo({
    required IconData icone,
    required String titulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$titulo: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: valor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _alterarStatus(String novoStatus) async {
    if (!_podeAlterarStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você não tem permissão para alterar o status.'),
        ),
      );
      return;
    }

    final usuarioLogadoId = AppSession.usuarioLogadoId;

    if (_tarefaAtual.id == null || usuarioLogadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível alterar o status. Faça login com um usuário válido.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _alterandoStatus = true;
    });

    try {
      final tarefaAtualizada = await _tarefaService.alterarStatus(
        tarefaId: _tarefaAtual.id!,
        usuarioId: usuarioLogadoId,
        statusNovo: novoStatus,
      );

      if (!mounted) return;

      setState(() {
        _tarefaAtual = tarefaAtualizada;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status alterado com sucesso!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar status: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _alterandoStatus = false;
        });
      }
    }
  }

  void _abrirDialogAlterarStatus() {
    String statusSelecionado = _tarefaAtual.statusAtual ?? 'PENDENTE';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar Status'),
          content: DropdownButtonFormField<String>(
            initialValue: statusSelecionado,
            decoration: const InputDecoration(
              labelText: 'Novo status',
              prefixIcon: Icon(Icons.flag),
            ),
            items: _statusTarefa.map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                statusSelecionado = value;
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
                _alterarStatus(statusSelecionado);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _abrirEditarTarefa() async {
    final resultado = await Navigator.push<Tarefa>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarTarefaScreen(
          tarefa: _tarefaAtual,
        ),
      ),
    );

    if (resultado != null) {
      setState(() {
        _tarefaAtual = resultado;
      });
    }
  }

  Widget _botaoAcao({
    required IconData icone,
    required String texto,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icone),
        label: Text(texto),
      ),
    );
  }

  Widget _avisoPermissao() {
    if (_acessoNormal) {
      return const SizedBox.shrink();
    }

    String mensagem;

    if (widget.permissaoCompartilhamento == 'VISUALIZAR') {
      mensagem =
          'Sua permissão é VISUALIZAR. Você pode consultar a tarefa, comentários e histórico, mas não pode alterar dados.';
    } else if (widget.permissaoCompartilhamento == 'EDITAR_STATUS') {
      mensagem =
          'Sua permissão é EDITAR_STATUS. Você pode alterar apenas o status da tarefa.';
    } else {
      mensagem =
          'Sua permissão é EDITAR_TAREFA. Você pode alterar status e editar os dados principais da tarefa.';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange),
      ),
      child: Text(
        mensagem,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _avisoUsuarioLogado() {
    if (!AppSession.estaLogado) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red),
        ),
        child: const Text(
          'Nenhum usuário está logado. Para registrar corretamente comentários e alterações de status, faça login com um usuário válido.',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green),
      ),
      child: Text(
        'Usuário logado: ${AppSession.nomeUsuarioLogado}',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusCor = _corStatus(_tarefaAtual.statusAtual);
    final prioridadeCor = _corPrioridade(_tarefaAtual.prioridade);
    final permissaoCor = _acessoNormal
        ? Colors.purple
        : _corPermissao(widget.permissaoCompartilhamento);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Tarefa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 28,
                        child: Text(
                          _tarefaAtual.id?.toString() ?? '?',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        _tarefaAtual.titulo ?? 'Sem título',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _etiqueta(
                            texto: _tarefaAtual.statusAtual ?? '-',
                            cor: statusCor,
                          ),
                          _etiqueta(
                            texto: _tarefaAtual.prioridade ?? '-',
                            cor: prioridadeCor,
                          ),
                          _etiqueta(
                            texto: _textoPermissao,
                            cor: permissaoCor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Descrição',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _tarefaAtual.descricao ?? 'Sem descrição',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _linhaInfo(
                      icone: Icons.person,
                      titulo: 'Criador',
                      valor:
                          _tarefaAtual.usuarioCriador?.nome ?? 'Não informado',
                    ),
                    _linhaInfo(
                      icone: Icons.email,
                      titulo: 'E-mail do criador',
                      valor: _tarefaAtual.usuarioCriador?.email ??
                          'Não informado',
                    ),
                    _linhaInfo(
                      icone: Icons.calendar_today,
                      titulo: 'Data limite',
                      valor: _formatarData(_tarefaAtual.dataLimite),
                    ),
                    _linhaInfo(
                      icone: Icons.access_time,
                      titulo: 'Criada em',
                      valor: _formatarData(_tarefaAtual.dataCriacao),
                    ),
                    _linhaInfo(
                      icone: Icons.assignment_ind,
                      titulo: 'Responsável',
                      valor: _responsavelTexto,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Ações da Tarefa',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _avisoUsuarioLogado(),

                    _avisoPermissao(),

                    _botaoAcao(
                      icone: Icons.flag,
                      texto: _alterandoStatus
                          ? 'Alterando status...'
                          : 'Alterar Status',
                      onPressed: _podeAlterarStatus && !_alterandoStatus
                          ? _abrirDialogAlterarStatus
                          : null,
                    ),

                    if (_podeEditarTarefa)
                      _botaoAcao(
                        icone: Icons.edit,
                        texto: 'Editar Tarefa',
                        onPressed: _abrirEditarTarefa,
                      ),

                    _botaoAcao(
                      icone: Icons.comment,
                      texto: 'Ver Comentários',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ComentariosScreen(
                              tarefa: _tarefaAtual,
                            ),
                          ),
                        );
                      },
                    ),

                    _botaoAcao(
                      icone: Icons.history,
                      texto: 'Ver Histórico de Status',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HistoricoStatusScreen(
                              tarefa: _tarefaAtual,
                            ),
                          ),
                        );
                      },
                    ),

                    if (_podeCompartilhar)
                      _botaoAcao(
                        icone: Icons.share,
                        texto: 'Compartilhar Tarefa',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CompartilharTarefaScreen(
                                tarefaInicial: _tarefaAtual,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}