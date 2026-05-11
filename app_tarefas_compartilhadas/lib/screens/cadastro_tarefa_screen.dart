import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/tarefa_service.dart';
import '../services/usuario_service.dart';

class CadastroTarefaScreen extends StatefulWidget {
  const CadastroTarefaScreen({super.key});

  @override
  State<CadastroTarefaScreen> createState() => _CadastroTarefaScreenState();
}

class _CadastroTarefaScreenState extends State<CadastroTarefaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  final TarefaService _tarefaService = TarefaService();
  final UsuarioService _usuarioService = UsuarioService();

  List<Usuario> _usuarios = [];

  Usuario? _usuarioSelecionado;
  int? _usuarioResponsavelId;

  String _statusSelecionado = 'PENDENTE';
  String _prioridadeSelecionada = 'MEDIA';
  DateTime? _dataLimite;

  bool _carregandoUsuarios = true;
  bool _salvando = false;

  final List<String> _statusTarefa = [
    'PENDENTE',
    'EM_ANDAMENTO',
    'CONCLUIDA',
    'CANCELADA',
  ];

  final List<String> _prioridades = [
    'BAIXA',
    'MEDIA',
    'ALTA',
    'URGENTE',
  ];

  @override
  void initState() {
    super.initState();
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
        _usuarioSelecionado = usuarios.isNotEmpty ? usuarios.first : null;
        _usuarioResponsavelId =
            usuarios.isNotEmpty ? usuarios.first.id : null;
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

  Future<void> _salvarTarefa() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_usuarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastre ou selecione um usuário antes de criar a tarefa.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final tarefa = Tarefa(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        statusAtual: _statusSelecionado,
        prioridade: _prioridadeSelecionada,
        dataLimite: _dataLimite != null
            ? DateTime(
                _dataLimite!.year,
                _dataLimite!.month,
                _dataLimite!.day,
                23,
                59,
              ).toIso8601String()
            : null,
        usuarioCriador: Usuario(
          id: _usuarioSelecionado!.id,
        ),
        usuarioResponsavelId: _usuarioResponsavelId,
      );

      await _tarefaService.criar(tarefa);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarefa cadastrada com sucesso!'),
        ),
      );

      _tituloController.clear();
      _descricaoController.clear();

      setState(() {
        _statusSelecionado = 'PENDENTE';
        _prioridadeSelecionada = 'MEDIA';
        _dataLimite = null;
        _usuarioSelecionado = _usuarios.isNotEmpty ? _usuarios.first : null;
        _usuarioResponsavelId =
            _usuarios.isNotEmpty ? _usuarios.first.id : null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar tarefa: $e'),
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

  Widget _dropdownUsuarioCriador() {
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
          'Nenhum usuário cadastrado. Cadastre um usuário antes de criar uma tarefa.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<Usuario>(
        initialValue: _usuarioSelecionado,
        decoration: const InputDecoration(
          labelText: 'Usuário criador',
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
        validator: (value) {
          if (value == null) {
            return 'Selecione o usuário criador';
          }
          return null;
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
      return const SizedBox.shrink();
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

  Widget _dropdownTexto({
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        items: options.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
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
        title: const Text('Cadastrar Tarefa'),
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
                    Icons.add_task,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nova Tarefa',
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

                  _dropdownTexto(
                    label: 'Status',
                    icon: Icons.flag,
                    value: _statusSelecionado,
                    options: _statusTarefa,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _statusSelecionado = value;
                        });
                      }
                    },
                  ),

                  _dropdownTexto(
                    label: 'Prioridade',
                    icon: Icons.priority_high,
                    value: _prioridadeSelecionada,
                    options: _prioridades,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _prioridadeSelecionada = value;
                        });
                      }
                    },
                  ),

                  _campoDataLimite(),

                  _dropdownUsuarioCriador(),

                  _dropdownResponsavel(),

                  const SizedBox(height: 8),

                  FilledButton.icon(
                    onPressed: _salvando ? null : _salvarTarefa,
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _salvando ? 'Salvando...' : 'Salvar Tarefa',
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