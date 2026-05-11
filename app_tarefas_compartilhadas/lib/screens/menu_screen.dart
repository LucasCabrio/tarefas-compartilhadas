import 'package:flutter/material.dart';

import 'amigos_screen.dart';
import 'cadastro_tarefa_screen.dart';
import 'cadastro_usuario_screen.dart';
import 'compartilhar_tarefa_screen.dart';
import 'historico_status_screen.dart';
import 'tarefas_screen.dart';
import 'usuarios_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void abrir(BuildContext context, Widget tela) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => tela),
    );
  }

  Widget _opcao(
    BuildContext context, {
    required String titulo,
    required String descricao,
    required IconData icone,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(38),
          child: Icon(
            icone,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            descricao,
            style: const TextStyle(height: 1.3),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget _tituloSecao(String texto) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 8,
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas Compartilhadas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Menu Principal',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Gerencie usuários, tarefas, amizades, permissões de compartilhamento e acompanhe o histórico de alterações do sistema.',
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          _tituloSecao('Usuários'),

          _opcao(
            context,
            titulo: 'Novo Usuário',
            descricao: 'Cadastre uma nova pessoa para utilizar o sistema.',
            icone: Icons.person_add,
            onTap: () {
              abrir(context, const CadastroUsuarioScreen());
            },
          ),

          _opcao(
            context,
            titulo: 'Gerenciar Usuários',
            descricao: 'Consulte os usuários cadastrados e exclua registros, se necessário.',
            icone: Icons.people,
            onTap: () {
              abrir(context, const UsuariosScreen());
            },
          ),

          _tituloSecao('Tarefas'),

          _opcao(
            context,
            titulo: 'Nova Tarefa',
            descricao: 'Crie uma tarefa, defina prioridade, status, prazo e usuário criador.',
            icone: Icons.add_task,
            onTap: () {
              abrir(context, const CadastroTarefaScreen());
            },
          ),

          _opcao(
            context,
            titulo: 'Minhas Tarefas',
            descricao: 'Visualize as tarefas cadastradas, acesse detalhes, comentários e histórico.',
            icone: Icons.task_alt,
            onTap: () {
              abrir(context, const TarefasScreen());
            },
          ),

          _tituloSecao('Relacionamentos e Compartilhamento'),

          _opcao(
            context,
            titulo: 'Gerenciar Amigos',
            descricao: 'Envie, aceite ou recuse solicitações de amizade entre usuários.',
            icone: Icons.group,
            onTap: () {
              abrir(context, const AmigosScreen());
            },
          ),

          _opcao(
            context,
            titulo: 'Compartilhar Tarefa',
            descricao: 'Compartilhe tarefas com amigos e defina permissões de acesso.',
            icone: Icons.share,
            onTap: () {
              abrir(context, const CompartilharTarefaScreen());
            },
          ),

          _tituloSecao('Acompanhamento'),

          _opcao(
            context,
            titulo: 'Histórico de Alterações',
            descricao: 'Consulte todas as mudanças de status registradas nas tarefas.',
            icone: Icons.history,
            onTap: () {
              abrir(context, const HistoricoStatusScreen());
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}