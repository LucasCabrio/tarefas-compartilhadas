# Frontend - Tarefas Compartilhadas entre Amigos

Este projeto representa o frontend da aplicação **Tarefas Compartilhadas entre Amigos**, desenvolvido em **Flutter com Dart**.

O frontend é responsável pela interface visual do sistema e pela comunicação com o backend Java Spring Boot por meio de requisições HTTP.

## Objetivo do Frontend

O objetivo do aplicativo Flutter é permitir que o usuário interaja com o sistema de forma visual, realizando operações como:

- Login;
- Cadastro de usuários;
- Cadastro de tarefas;
- Gerenciamento de amizades;
- Compartilhamento de tarefas;
- Controle de permissões;
- Comentários em tarefas;
- Consulta ao histórico de status.

## Tecnologias Utilizadas

- Flutter
- Dart
- Material Design
- HTTP package

## Estrutura Principal do Flutter

A pasta principal do código é a pasta `lib`.

```text
lib
│
├── models
├── screens
├── services
├── utils
└── main.dart
```
## Pasta models

A pasta models contém as classes que representam os dados recebidos e enviados para o backend.

Arquivos principais:
- usuario.dart
- tarefa.dart
- amizade.dart
- tarefa_compartilhada.dart
- comentario_tarefa.dart
- historico_status.dart

Essas classes fazem a conversão entre objetos Dart e JSON.

## Pasta screens

A pasta screens contém as telas do aplicativo.

Principais telas:
- login_screen.dart
- menu_screen.dart
- cadastro_usuario_screen.dart
- usuarios_screen.dart
- cadastro_tarefa_screen.dart
- tarefas_screen.dart
- detalhe_tarefa_screen.dart
- editar_tarefa_screen.dart
- amigos_screen.dart
- compartilhar_tarefa_screen.dart
- comentarios_screen.dart
- historico_status_screen.dart

## Pasta services

A pasta services contém as classes responsáveis pela comunicação com o backend.

Principais arquivos:
- api_config.dart
- api_service.dart
- usuario_service.dart
- tarefa_service.dart
- amizade_service.dart
- tarefa_compartilhada_service.dart
- comentario_tarefa_service.dart
- historico_status_service.dart

Cada service chama os endpoints do backend e transforma as respostas em objetos Dart.

## Pasta utils

A pasta utils contém classes auxiliares.

Atualmente, o principal arquivo é:
- app_session.dart

Esse arquivo guarda temporariamente o usuário logado no aplicativo.

## Login

O sistema possui uma tela de login simples.

O usuário informa:
- E-mail;
- Senha.

O Flutter consulta os usuários cadastrados no backend e verifica se existe um usuário com os dados informados.

Após o login, o usuário é salvo temporariamente na classe AppSession.

## AppSession

A classe AppSession armazena o usuário logado enquanto o aplicativo está aberto.

Ela permite identificar:
- Usuário logado
- ID do usuário logado
- Nome do usuário logado

Essa informação é usada para controlar permissões no aplicativo.

Exemplos:
- Somente o destinatário pode aceitar amizade.
- Somente o criador pode alterar permissão.
- O histórico registra quem alterou o status.

## Menu Principal

O menu principal organiza as funções em seções:
- Usuários
- Tarefas
- Relacionamentos e Compartilhamento
- Acompanhamento

Opções disponíveis:
- Novo Usuário
- Gerenciar Usuários
- Nova Tarefa
- Minhas Tarefas
- Gerenciar Amigos
- Compartilhar Tarefa
- Histórico de Alterações

## Usuários

O frontend permite:
- Cadastrar usuário;
- Listar usuários;
- Excluir usuário.
- Tarefas

O frontend permite:
- Cadastrar tarefa;
- Listar tarefas;
- Visualizar detalhes da tarefa;
- Editar tarefa;
- Alterar status;
- Excluir tarefa.
- Detalhes da Tarefa

Na tela de detalhes é possível visualizar:
- Título;
- Descrição;
- Status;
- Prioridade;
- Criador;
- E-mail do criador;
- Data limite;
- Data de criação;
- Responsável.

Também é possível acessar ações como:
- Alterar Status
- Editar Tarefa
- Ver Comentários
- Ver Histórico de Status
- Compartilhar Tarefa

As ações exibidas dependem da permissão do usuário.

## Detalhes da Tarefa

Na tela de detalhes é possível visualizar:
- Título;
- Descrição;
- Status;
- Prioridade;
- Criador;
- E-mail do criador;
- Data limite;
- Data de criação;
- Responsável.

Também é possível acessar ações como:
- Alterar Status
- Editar Tarefa
- Ver Comentários
- Ver Histórico de Status
- Compartilhar Tarefa

As ações exibidas dependem da permissão do usuário.

## Diferença entre Criador, Responsável e Compartilhado

O sistema diferencia três papéis principais:
- Criador
- Responsável
- Compartilhado com

- Criador

É o usuário que cadastrou a tarefa.

Exemplo:
Criador: João

- Responsável

É o usuário definido para executar ou acompanhar a tarefa.

Exemplo:
Responsável: Paulo

- Compartilhado com

É o usuário que recebeu acesso à tarefa por meio do compartilhamento.

Exemplo:
Compartilhada com: Mateus

Essa separação permite organizar melhor a função de cada usuário dentro da tarefa.

## Amizades

A tela de amigos permite criar solicitações de amizade.

A regra implementada é:
- Paulo Junior enviou solicitação para João Pedro
    ↓
- Somente João Pedro pode aceitar ou recusar
    ↓
- Paulo Junior não pode aceitar a própria solicitação
    ↓
- Outro usuário também não pode aceitar ou recusar

Se o usuário logado for o destinatário, aparecem os botões:
- Aceitar
- Recusar

Se o usuário logado for o solicitante, aparece:
- Aguardando resposta do destinatário

Se for outro usuário, aparece:
- Você não pode responder esta solicitação

## Compartilhamento de Tarefas

A tela de compartilhamento permite que o criador da tarefa compartilhe uma tarefa com um amigo aceito.

O usuário escolhe:
- Tarefa;
- Usuário que receberá a tarefa;
- Permissão.

As permissões disponíveis são:
- VISUALIZAR
- EDITAR_STATUS
- EDITAR_TAREFA

PERMISSÕES

VISUALIZAR
- Permite apenas visualizar a tarefa.

EDITAR_STATUS
- Permite visualizar e alterar o status da tarefa.

EDITAR_TAREFA
- Permite visualizar, alterar status e editar os dados da tarefa.

Alteração de Permissão
- O criador da tarefa pode alterar a permissão de um compartilhamento já existente.

Exemplo:
- VISUALIZAR → EDITAR_STATUS
- EDITAR_STATUS → EDITAR_TAREFA

O usuário compartilhado não pode alterar a própria permissão.

## Comentários

A tela de comentários permite adicionar e visualizar comentários relacionados a uma tarefa.

Cada comentário exibe:
- Autor;
- Texto;
- Data do comentário.
- Histórico de Status

A tela de histórico mostra as alterações realizadas no status das tarefas.

Cada histórico exibe:
- Tarefa;
- Status anterior;
- Novo status;
- Usuário que realizou a alteração;
- Data da alteração.

## Comunicação com o Backend

A URL base da API fica no arquivo:

```text
lib/services/api_config.dart
```

Exemplo:

class ApiConfig {
  static const String baseUrl = 'http://localhost:8080';
}

Para execução no navegador, normalmente pode ser usado:

http://localhost:8080

Para execução em emulador Android, pode ser necessário usar:

http://10.0.2.2:8080

## Como Executar o Frontend

- Abrir a pasta do Flutter no VS Code.
- Verificar se o backend está rodando no IntelliJ.

- Executar:
   - flutter pub get

- Verificar se há problemas:
   - flutter analyze

- Rodar o projeto:
   - flutter run

Fluxo Geral da Aplicação
- Login
    ↓
- Menu Principal
    ↓
- Cadastro de usuários
    ↓
- Criação de amizades
    ↓
- Criação de tarefas
    ↓
- Compartilhamento de tarefas
    ↓
- Controle de permissões
    ↓
- Comentários e histórico

## Observações

Este frontend foi desenvolvido com finalidade acadêmica, com foco em integração com API REST, navegação entre telas, formulários, regras de permissão e consumo de dados do backend.

O login utilizado é simples e funciona apenas como controle local para identificar o usuário logado durante a execução do aplicativo.

Em uma aplicação real, seria recomendado usar autenticação com token, como JWT.
