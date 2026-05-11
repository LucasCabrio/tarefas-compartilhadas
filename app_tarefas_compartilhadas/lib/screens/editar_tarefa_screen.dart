import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/tarefa_service.dart';
import '../services/usuario_service.dart';
import '../utils/app_session.dart';

class EditarTarefaScreen extends StatefulWidget {
  final Tarefa tarefa;

  const EditarTarefaScreen({
    super.key,
    required this.tarefa,
  });

  @override
  State<EditarTarefaScreen> createState() => _EditarTarefaScreenState();
}

class _EditarTarefaScreenState extends State<EditarTarefaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  final TarefaService _tarefaService = TarefaService();
  final UsuarioService _usuarioService = UsuarioService();

  List<Usuario> _usuarios = [];

  String _prioridadeSelecionada = 'MEDIA';
  int? _usuarioResponsavelId;
  DateTime? _dataLimite;

  bool _carregandoUsuarios = true;
  bool _salvando = false;

  final List<String> _prioridades = [
    'BAIXA',
    'MEDIA',
    'ALTA',
    'URGENTE',
  ];

  @override
  void initState() {
    super.initState();

    _tituloController.text = widget.tarefa.titulo ?? '';
    _descricaoController.text = widget.tarefa.descricao ?? '';
    _prioridadeSelecionada = widget.tarefa.prioridade ?? 'MEDIA';
    _usuarioResponsavelId = widget.tarefa.usuarioResponsavelId;

    if (widget.tarefa.dataLimite != null &&
        widget.tarefa.dataLimite!.isNotEmpty) {
      try {
        _dataLimite = DateTime.parse(widget.tarefa.dataLimite!);
      } catch (e) {
        _dataLimite = null;
      }
    }

    _carregarUsuarios();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarUsuarios() async {
    try {
      final usuarios = await _usuarioService.listar();

      if (!mounted) return;

      setState(() {
        _usuarios = usuarios;
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

  Future<void> _selecionarDataLimite() async {
    final dataAtual = DateTime.now();

    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _dataLimite ?? dataAtual,
      firstDate: DateTime(dataAtual.year - 1),
      lastDate: DateTime(dataAtual.year + 5),
    );

    if (dataEscolhida != null) {
      setState(() {
        _dataLimite = dataEscolhida;
      });
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) {
      return 'Nenhuma data selecionada';
    }

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano';
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.tarefa.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível identificar a tarefa.'),
        ),
      );
      return;
    }

    if (widget.tarefa.usuarioCriador?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível identificar o criador da tarefa.'),
        ),
      );
      return;
    }

    final usuarioLogadoId = AppSession.usuarioLogadoId;

    if (usuarioLogadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível editar. Faça login com um usuário válido.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final dataLimiteFormatada = _dataLimite != null
          ? DateTime(
              _dataLimite!.year,
              _dataLimite!.month,
              _dataLimite!.day,
              23,
              59,
            ).toIso8601String()
          : null;

      final tarefaAtualizada = await _tarefaService.editarDadosPrincipais(
        id: widget.tarefa.id!,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        statusAtual: widget.tarefa.statusAtual ?? 'PENDENTE',
        prioridade: _prioridadeSelecionada,
        dataLimite: dataLimiteFormatada,
        usuarioCriadorId: widget.tarefa.usuarioCriador!.id!,
        usuarioLogadoId: usuarioLogadoId,
        usuarioResponsavelId: _usuarioResponsavelId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarefa atualizada com sucesso!'),
        ),
      );

      Navigator.pop(context, tarefaAtualizada);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar tarefa: $e'),
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: validator,
      ),
    );
  }

  Widget _dropdownPrioridade() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: _prioridadeSelecionada,
        decoration: const InputDecoration(
          labelText: 'Prioridade',
          prefixIcon: Icon(Icons.priority_high),
        ),
        items: _prioridades.map((prioridade) {
          return DropdownMenuItem<String>(
            value: prioridade,
            child: Text(prioridade),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _prioridadeSelecionada = value;
            });
          }
        },
      ),
    );
  }

  Widget _dropdownResponsavel() {
    if (_carregandoUsuarios) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_usuarios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text(
          'Nenhum usuário cadastrado para definir responsável.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int?>(
        initialValue: _usuarioResponsavelId,
        decoration: const InputDecoration(
          labelText: 'Responsável pela tarefa',
          prefixIcon: Icon(Icons.assignment_ind),
        ),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('Sem responsável definido'),
          ),
          ..._usuarios.map((usuario) {
            return DropdownMenuItem<int?>(
              value: usuario.id,
              child: Text('${usuario.id} - ${usuario.nome ?? 'Sem nome'}'),
            );
          }),
        ],
        onChanged: (usuarioId) {
          setState(() {
            _usuarioResponsavelId = usuarioId;
          });
        },
      ),
    );
  }

  Widget _campoDataLimite() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _selecionarDataLimite,
        borderRadius: BorderRadius.circular(14),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Data limite',
            prefixIcon: Icon(Icons.calendar_month),
          ),
          child: Text(
            _formatarData(_dataLimite),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarefa'),
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
                    Icons.edit_note,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Editar Dados da Tarefa',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _campoTexto(
                    controller: _tituloController,
                    label: 'Título',
                    icon: Icons.title,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o título da tarefa';
                      }
                      return null;
                    },
                  ),

                  _campoTexto(
                    controller: _descricaoController,
                    label: 'Descrição',
                    icon: Icons.description,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a descrição da tarefa';
                      }
                      return null;
                    },
                  ),

                  _dropdownPrioridade(),

                  _campoDataLimite(),

                  _dropdownResponsavel(),

                  const SizedBox(height: 8),

                  FilledButton.icon(
                    onPressed: _salvando ? null : _salvarAlteracoes,
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _salvando ? 'Salvando...' : 'Salvar Alterações',
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