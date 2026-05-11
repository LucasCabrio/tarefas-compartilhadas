import 'package:flutter/material.dart';

import '../models/historico_status.dart';
import '../models/tarefa.dart';
import '../services/historico_status_service.dart';

class HistoricoStatusScreen extends StatefulWidget {
  final Tarefa? tarefa;

  const HistoricoStatusScreen({
    super.key,
    this.tarefa,
  });

  @override
  State<HistoricoStatusScreen> createState() => _HistoricoStatusScreenState();
}

class _HistoricoStatusScreenState extends State<HistoricoStatusScreen> {
  final HistoricoStatusService _historicoService = HistoricoStatusService();

  Future<List<HistoricoStatus>> _historicoFuture = Future.value([]);

  bool get _ehHistoricoDeUmaTarefa => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  void _carregarHistorico() {
    if (widget.tarefa?.id != null) {
      _historicoFuture =
          _historicoService.listarPorTarefa(widget.tarefa!.id!);
    } else {
      _historicoFuture = _historicoService.listar();
    }
  }

  Future<void> _atualizarHistorico() async {
    setState(() {
      _carregarHistorico();
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

  Widget _cardHistorico(HistoricoStatus historico) {
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
                    historico.id?.toString() ?? '?',
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Alteração de Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _etiquetaStatus(historico.statusAnterior),
                const Icon(Icons.arrow_forward),
                _etiquetaStatus(historico.statusNovo),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.task_alt, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tarefa: ${historico.tarefa?.titulo ?? '-'}',
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
                    'Alterado por: ${historico.usuario?.nome ?? '-'}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.email, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'E-mail: ${historico.usuario?.email ?? '-'}',
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
                    'Data da alteração: ${_formatarData(historico.dataAlteracao)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaHistorico(List<HistoricoStatus> historicos) {
    if (historicos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Nenhuma alteração de status registrada.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Column(
      children: historicos.map((historico) {
        return _cardHistorico(historico);
      }).toList(),
    );
  }

  Widget _cabecalho() {
    if (_ehHistoricoDeUmaTarefa) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.history,
                size: 54,
              ),
              const SizedBox(height: 12),
              Text(
                widget.tarefa?.titulo ?? 'Tarefa sem título',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.tarefa?.descricao ?? '',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 54,
            ),
            SizedBox(height: 12),
            Text(
              'Histórico Geral',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Consulte todas as alterações de status realizadas nas tarefas.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tituloTela = _ehHistoricoDeUmaTarefa
        ? 'Histórico de Status'
        : 'Histórico Geral';

    return Scaffold(
      appBar: AppBar(
        title: Text(tituloTela),
        actions: [
          IconButton(
            onPressed: _atualizarHistorico,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _atualizarHistorico,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _cabecalho(),

            const SizedBox(height: 20),

            const Text(
              'Alterações Registradas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            FutureBuilder<List<HistoricoStatus>>(
              future: _historicoFuture,
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
                        'Erro ao carregar histórico:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final historicos = snapshot.data ?? [];

                return _listaHistorico(historicos);
              },
            ),
          ],
        ),
      ),
    );
  }
}