import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/tarefa_service.dart';
import 'detalhe_tarefa_screen.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  final TarefaService _tarefaService = TarefaService();

  late Future<List<Tarefa>> _tarefasFuture;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  void _carregarTarefas() {
    _tarefasFuture = _tarefaService.listar();
  }

  Future<void> _atualizarLista() async {
    setState(() {
      _carregarTarefas();
    });
  }

  Future<void> _excluirTarefa(int id) async {
    try {
      await _tarefaService.deletar(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarefa excluída com sucesso!'),
        ),
      );

      _atualizarLista();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir tarefa: $e'),
        ),
      );
    }
  }

  void _confirmarExclusao(Tarefa tarefa) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text(
            'Deseja realmente excluir a tarefa "${tarefa.titulo ?? ''}"?',
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

                if (tarefa.id != null) {
                  _excluirTarefa(tarefa.id!);
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
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

  Widget _etiqueta({
    required String texto,
    required Color cor,
  }) {
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
        texto,
        style: TextStyle(
          color: cor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _cardTarefa(Tarefa tarefa) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalheTarefaScreen(tarefa: tarefa),
          ),
        );

        _atualizarLista();
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      tarefa.id?.toString() ?? '?',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tarefa.titulo ?? 'Sem título',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _confirmarExclusao(tarefa);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tarefa.descricao ?? 'Sem descrição',
                style: TextStyle(
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _etiqueta(
                    texto: tarefa.statusAtual ?? '-',
                    cor: _corStatus(tarefa.statusAtual),
                  ),
                  _etiqueta(
                    texto: tarefa.prioridade ?? '-',
                    cor: _corPrioridade(tarefa.prioridade),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Criador: ${tarefa.usuarioCriador?.nome ?? '-'}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Data limite: ${_formatarData(tarefa.dataLimite)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Criada em: ${_formatarData(tarefa.dataCriacao)}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conteudoLista(List<Tarefa> tarefas) {
    if (tarefas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma tarefa cadastrada.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _atualizarLista,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tarefas.length,
        itemBuilder: (context, index) {
          final tarefa = tarefas[index];
          return _cardTarefa(tarefa);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas Cadastradas'),
        actions: [
          IconButton(
            onPressed: _atualizarLista,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Tarefa>>(
        future: _tarefasFuture,
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
                  'Erro ao carregar tarefas:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final tarefas = snapshot.data ?? [];

          return _conteudoLista(tarefas);
        },
      ),
    );
  }
}