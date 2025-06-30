# Rotary API - Sistema de Gestão de Empréstimos de Órteses

## 📋 Sobre o Projeto

A Rotary API é um sistema de gerenciamento de empréstimos de órteses desenvolvido para o Rotary Club. O sistema permite o controle completo do estoque de órteses, cadastro de requerentes, dependentes e gestão de empréstimos com prazo de devolução.

## 🏗️ Arquitetura do Projeto

### Stack Tecnológica

- **Framework**: .NET 8.0 (ASP.NET Core Web API)
- **Banco de Dados**: PostgreSQL
- **Cache**: Redis com Microsoft Hybrid Cache
- **Documentação**: Swagger/Scalar API Reference
- **Autenticação**: API Key Authentication
- **ORM**: Entity Framework Core
- **Containerização**: Docker

### Estrutura de Pastas

```
api/
├── Auth/                          # Módulo de autenticação
│   ├── AuthController.cs          # Controller de autenticação
│   ├── AuthCacheService.cs        # Serviço de cache para auth
│   ├── Dto/                       # DTOs de autenticação
│   └── Entity/User.cs             # Entidade de usuário
├── DB/                            # Contextos de banco de dados
│   ├── ApiDbContext.cs            # Contexto principal da aplicação
│   └── AuthDbContext.cs           # Contexto de autenticação
├── Extensions/                    # Extensões de configuração
│   ├── BuilderExtensions.cs       # Configurações do builder
│   └── AppExtensions.cs           # Configurações da aplicação
├── Middlewares/                   # Middlewares customizados
│   └── ApiKeyAuthMiddleware.cs    # Middleware de autenticação por API Key
├── Modules/                       # Módulos funcionais
│   ├── Applicants/                # Gestão de requerentes
│   ├── Dependents/                # Gestão de dependentes
│   ├── Items/                     # Gestão de itens individuais
│   ├── Loans/                     # Gestão de empréstimos
│   ├── OrthopedicBanks/          # Gestão de bancos ortopédicos
│   └── Stocks/                    # Gestão de estoques
├── Migrations/                    # Migrações do banco de dados
├── Swagger/                       # Configurações do Swagger
├── Program.cs                     # Ponto de entrada da aplicação
└── docker-compose.yml             # Configuração Docker
```

## 🗂️ Módulos Funcionais

### 1. **OrthopedicBanks** (Bancos Ortopédicos)

- Representa os bancos/fornecedores de órteses
- Gerencia informações sobre as fontes dos equipamentos

### 2. **Stocks** (Estoques)

- Categoriza os tipos de órteses disponíveis
- Relaciona-se com os bancos ortopédicos
- Contém múltiplos itens do mesmo tipo

### 3. **Items** (Itens)

- Representa itens individuais de órteses
- Cada item tem um código serial único
- Estados possíveis: `AVAILABLE`, `UNAVAILABLE`, `MAINTENANCE`, `LOST`, `DONATED`
- Vinculado a um estoque específico

### 4. **Applicants** (Requerentes)

- Pessoas que solicitam empréstimos de órteses
- Podem ser beneficiários diretos ou responsáveis por dependentes
- Campos: Nome, CPF (único), Email, Telefone, Endereço
- Podem ter múltiplos dependentes

### 5. **Dependents** (Dependentes)

- Pessoas dependentes de um requerente
- Também podem receber órteses em empréstimo
- Vinculados a um requerente principal

### 6. **Loans** (Empréstimos)

- Controla os empréstimos de órteses
- Prazo padrão de 3 meses
- Vincula requerente/dependente ao item emprestado
- Registra responsável pelo empréstimo e motivo

### 7. **Auth** (Autenticação)

- Sistema de autenticação de usuários
- Baseado em ASP.NET Core Identity

## 🔗 Relacionamentos Entre Entidades

```
OrthopedicBank (1) ──── (N) Stock
Stock (1) ──── (N) Item
Applicant (1) ──── (N) Dependent
Applicant (1) ──── (N) Loan
Item (1) ──── (N) Loan
```

### Regras de Negócio dos Relacionamentos:

- **Stock → Items**: Exclusão em cascata (ao excluir estoque, exclui todos os itens)
- **Applicant → Dependents**: Exclusão em cascata (ao excluir requerente, exclui dependentes)
- **Loan → Applicant/Item**: Restrição de exclusão (não permite excluir se houver empréstimos ativos)

## 🛠️ Configurações e Funcionalidades

### Cache Híbrido

- **Memoria Local**: Expira em 10 segundos (Configuração padrão)
- **Redis**: Cache distribuído para ambiente de produção
- **Tamanho máximo**: 1MB por entrada

### Autenticação

- **API Key**: Middleware personalizado para validação de chave de API
- **Header obrigatório**: `X-Api-Key`
- **Exceções**: Rotas de documentação (`/swagger`, `/scalar`, `/openapi`)

### Documentação da API

- **Swagger**: Documentação técnica da API
- **Scalar**: Interface moderna e interativa para testes
- **Tema**: Deep Space com sidebar habilitada
- **Segurança**: Integração com esquema de API Key

### CORS

- Configurado para aceitar qualquer origem, método e cabeçalho
- Adequado para desenvolvimento (revisar para produção)

## 🗄️ Banco de Dados

### Contextos Separados

- **ApiDbContext**: Dados principais da aplicação
- **AuthDbContext**: Dados de autenticação e usuários

### Constraints e Índices

- **CPF único**: Para requerentes e dependentes
- **Índices**: Otimização para consultas por CPF e título de estoque

### Migrations

- Versionamento automático do schema
- Separadas por contexto (`app/` e `auth/`)

## 🚀 Como Executar

### Pré-requisitos

- .NET 8.0 SDK
- Docker e Docker Compose
- PostgreSQL (se não usar Docker)
- Redis (se não usar Docker)

### Execução Local

```bash
# Instalar dependências
dotnet restore

# Configurar variáveis de ambiente (.env)
DB_URL=Server=localhost;Port=5432;Database=rotarydb;UserId=postgres;Password=postgres;
API_KEY=your-secret-api-key

# Executar migrações
dotnet ef database update --context ApiDbContext
dotnet ef database update --context AuthDbContext

# Executar aplicação
dotnet run
```

## 📋 Variáveis de Ambiente

```env
DB_URL=Server=localhost;Port=5432;Database=rotarydb;UserId=postgres;Password=postgres;
API_KEY=your-secret-api-key-here
```

## 📚 Documentação da API

Após executar a aplicação, acesse:

- **Scalar (Recomendado)**: `http://localhost:8080/scalar/v1`
- **Swagger**: `http://localhost:8080/swagger`
- **OpenAPI JSON**: `http://localhost:8080/openapi/v1.json`

## 🔒 Segurança

### API Key Authentication

Todas as rotas (exceto documentação) requerem o header:

```
X-Api-Key: your-secret-api-key
```

### Middleware de Autenticação

- Validação automática em todas as requisições
- Rotas públicas configuradas para documentação
- Retorno 401 para chaves inválidas ou ausentes

## 🧪 Padrões de Desenvolvimento

### Arquitetura Modular

- Cada funcionalidade isolada em seu módulo
- DTOs separados para Request/Response
- Exemplos de documentação para cada endpoint

### Clean Code

- Separação de responsabilidades
- Injeção de dependência nativa do .NET
- Configurações centralizadas em Extensions

### Entity Framework

- Code First com Migrations
- Relacionamentos bem definidos
- Índices para performance

## 🚀 Deploy

### Produção

1. Configure as variáveis de ambiente adequadas
2. Utilize um banco PostgreSQL dedicado
3. Configure Redis para cache distribuído
4. Ajuste políticas CORS para domínios específicos
5. Implemente logging adequado
6. Configure SSL/TLS

### Monitoramento

- Logs estruturados disponíveis
- Health checks podem ser implementados
- Métricas de cache híbrido


## 📄 Licença

Este projeto está sob licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

**Rotary API v1.4** - Sistema de Gestão de Empréstimos de Órteses
