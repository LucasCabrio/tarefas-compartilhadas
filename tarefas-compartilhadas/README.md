# Tarefas Compartilhadas entre Amigos

API REST desenvolvida em Java com Spring Boot para um projeto academico de gerenciamento de tarefas compartilhadas entre amigos.

O sistema permite cadastrar usuarios, criar tarefas, registrar amizades, compartilhar tarefas com permissoes, alterar status com historico automatico e adicionar comentarios em tarefas.

## Tecnologias

### Backend

- Java 17
- Spring Boot 3.3.5
- Spring Web
- Spring Data JPA
- Hibernate
- H2 Database em memoria
- Lombok
- Bean Validation
- Springdoc OpenAPI / Swagger
- Maven

### Frontend

- Flutter
- Dart
- HTTP package
- Material Design

## Funcionalidades

- CRUD de usuarios
- CRUD de tarefas
- Criacao, aceite e recusa de amizades
- Compartilhamento de tarefas com amigos
- Permissoes de compartilhamento:
  - `VISUALIZAR`
  - `EDITAR_STATUS`
  - `EDITAR_TAREFA`
- Alteracao de status de tarefas
- Historico automatico de alteracao de status
- Comentarios em tarefas
- Consulta via endpoints REST
- Banco H2 em memoria
- Documentacao interativa com Swagger UI

## Regras Importantes

- O projeto nao possui autenticacao, login, JWT ou Spring Security.
- As permissoes sao validadas nas services usando IDs de usuarios enviados nas requisicoes.
- Apenas o criador da tarefa pode compartilhar a tarefa.
- A tarefa so pode ser compartilhada com usuarios que tenham amizade aceita com o criador.
- O historico de status e criado automaticamente ao alterar o status da tarefa.
- Comentarios so podem ser feitos pelo criador da tarefa ou por usuarios com quem a tarefa foi compartilhada.

## Como Executar

Clone o repositorio:

```bash
git clone <url-do-repositorio>
cd tarefas-compartilhadas
```

Execute o projeto:

```bash
mvn spring-boot:run
```

A API ficara disponivel em:

```text
http://localhost:8080
```

## Swagger

Com a aplicacao rodando, acesse:

```text
http://localhost:8080/swagger-ui.html
```

OpenAPI JSON:

```text
http://localhost:8080/v3/api-docs
```

## H2 Console

Com a aplicacao rodando, acesse:

```text
http://localhost:8080/h2-console
```

Configuracao:

```text
JDBC URL: jdbc:h2:mem:tarefasdb
User Name: sa
Password: 
```

## Endpoints

### Usuários

| Método | Endpoint | Descrição |
|---|---|---|
| POST | `/usuarios` | Cria um usuário |
| GET | `/usuarios` | Lista usuários |
| GET | `/usuarios/{id}` | Busca usuário por ID |
| PUT | `/usuarios/{id}` | Atualiza usuário |
| DELETE | `/usuarios/{id}` | Remove usuário |

### Tarefas

| Método | Endpoint | Descrição |
|---|---|---|
| POST | `/tarefas` | Cria uma tarefa |
| GET | `/tarefas` | Lista tarefas |
| GET | `/tarefas/{id}` | Busca tarefa por ID |
| PUT | `/tarefas/{id}` | Atualiza uma tarefa |
| PATCH | `/tarefas/{id}/status` | Altera o status da tarefa e registra histórico |
| DELETE | `/tarefas/{id}` | Remove tarefa |
| GET | `/usuarios/{id}/tarefas` | Lista tarefas criadas por um usuário |

### Tarefas Compartilhadas

| Método | Endpoint | Descrição |
|---|---|---|
| POST | `/tarefas-compartilhadas` | Compartilha uma tarefa com outro usuário |
| GET | `/tarefas-compartilhadas` | Lista compartilhamentos |
| GET | `/tarefas-compartilhadas/{id}` | Busca compartilhamento por ID |
| GET | `/usuarios/{id}/tarefas-compartilhadas` | Lista tarefas compartilhadas com um usuário |
| GET | `/tarefas/{id}/compartilhamentos` | Lista compartilhamentos de uma tarefa |
| PUT | `/tarefas-compartilhadas/{id}` | Atualiza a permissão do compartilhamento |
| DELETE | `/tarefas-compartilhadas/{id}` | Remove compartilhamento |

### Comentários

| Método | Endpoint | Descrição |
|---|---|---|
| POST | `/comentarios` | Cria um comentário |
| GET | `/comentarios` | Lista comentários |
| GET | `/comentarios/{id}` | Busca comentário por ID |
| GET | `/tarefas/{id}/comentarios` | Lista comentários de uma tarefa |
| DELETE | `/comentarios/{id}` | Remove comentário |

### Histórico de Status

| Método | Endpoint | Descrição |
|---|---|---|
| GET | `/historicos-status` | Lista históricos de status |
| GET | `/historicos-status/{id}` | Busca histórico por ID |
| GET | `/tarefas/{id}/historico-status` | Lista histórico de status de uma tarefa |

## Exemplos de JSON

### Criar Usuario

`POST /usuarios`

```json
{
  "nome": "Paulo",
  "email": "paulo@email.com",
  "senha": "123456",
  "telefone": "(16) 99999-9999"
}
```

### Criar Amizade

`POST /amizades`

```json
{
  "usuarioSolicitante": {
    "id": 1
  },
  "usuarioAmigo": {
    "id": 2
  }
}
```

### Criar Tarefa

`POST /tarefas`

```json
{
  "titulo": "Preparar apresentacao no Prezi",
  "descricao": "Criar os slides explicando a arquitetura do projeto",
  "statusAtual": "PENDENTE",
  "prioridade": "ALTA",
  "dataLimite": "2026-05-20T23:59:00",
  "usuarioCriador": {
    "id": 1
  }
}
```

### Editar Tarefa

`PUT /tarefas/1`

```json
{
  "usuarioResponsavelId": 1,
  "titulo": "Preparar apresentacao final no Prezi",
  "descricao": "Finalizar os slides da arquitetura e dos endpoints",
  "prioridade": "URGENTE",
  "dataLimite": "2026-05-22T23:59:00",
  "statusAtual": "PENDENTE"
}
```

### Compartilhar Tarefa

`POST /tarefas-compartilhadas`

```json
{
  "tarefa": {
    "id": 1
  },
  "usuarioCriadorId": 1,
  "usuarioCompartilhado": {
    "id": 2
  },
  "permissao": "EDITAR_STATUS"
}
```

### Alterar Permissao

`PUT /tarefas-compartilhadas/1`

```json
{
  "permissao": "EDITAR_TAREFA"
}
```

### Alterar Status

`PATCH /tarefas/1/status`

```json
{
  "usuarioId": 2,
  "statusNovo": "EM_ANDAMENTO"
}
```

### Criar Comentario

`POST /comentarios`

```json
{
  "tarefa": {
    "id": 1
  },
  "usuario": {
    "id": 2
  },
  "texto": "Vou revisar a parte dos endpoints."
}
```

## Ordem Recomendada Para Testar

1. Criar usuario Paulo com `POST /usuarios`.
2. Criar usuario Ana com `POST /usuarios`.
3. Criar amizade entre Paulo e Ana com `POST /amizades`.
4. Aceitar amizade com `PUT /amizades/{id}/aceitar`.
5. Criar tarefa para Paulo com `POST /tarefas`.
6. Compartilhar tarefa com Ana usando `POST /tarefas-compartilhadas`.
7. Alterar status da tarefa com `PATCH /tarefas/{id}/status`.
8. Consultar historico com `GET /tarefas/{id}/historico-status`.
9. Criar comentario com `POST /comentarios`.
10. Consultar comentarios com `GET /tarefas/{id}/comentarios`.

## Estrutura do Projeto

```text
tarefas-compartilhadas
│
├── Backend Spring Boot
│   ├── controllers
│   ├── services
│   ├── repositories
│   ├── models
│   └── enums
│
└── app_tarefas_compartilhadas
    └── lib
        ├── models
        ├── screens
        ├── services
        ├── utils
        └── main.dart
```

## Observacoes

Este projeto foi desenvolvido com foco academico. A proposta e manter a implementacao simples, funcional e facil de testar via Swagger ou Postman.
