# Rotary Project

## Visão Geral

O Rotary Project é um aplicativo multiplataforma desenvolvido em Flutter, estruturado em camadas para garantir escalabilidade e manutenção facilitada. O app utiliza arquitetura baseada em widgets e separação de responsabilidades, com as seguintes características técnicas:

- **Frontend:** Interface construída com Flutter, utilizando widgets customizados, navegação por rotas nomeadas e navegação por abas (BottomNavigationBar).
- **Gerenciamento de Estado:** Utilização do setState para controle local de estado nas páginas principais.
- **Integração com API REST:** Comunicação com backend via serviços (camada `core/api`), utilizando modelos para serialização/deserialização dos dados.
- **Autenticação:** Implementação de fluxo de autenticação, controle de sessão e interceptação de erros globais (ex: sessão expirada).
- **Organização Modular:** Código dividido em módulos (auth, pdt, core), facilitando a expansão de funcionalidades.
- **Responsividade:** Layout adaptado para diferentes tamanhos de tela, com uso de temas customizados e imagens.

O sistema foi projetado para atender clubes Rotary ou instituições que realizam empréstimos de equipamentos ortopédicos, permitindo o gerenciamento completo de usuários, categorias, itens e empréstimos.

---

## Roteiro de Apresentação

### 1. Tela de Autenticação

- **Login (SingInPage):**
  - Tela inicial do app, com logo e formulário de login.
  - Permite acesso ao sistema para usuários cadastrados.
  - Opções para cadastro e recuperação de senha.
- **Cadastro (SignUpPage):**
  - Formulário para criação de nova conta.
  - Campos para dados pessoais e senha.
- **Recuperação de Senha (ForgotPasswordPage):**
  - Permite solicitar redefinição de senha via e-mail.

### 2. Layout Principal (Layout)

- Navegação por abas na parte inferior:
  - **Categorias**
  - **Empréstimos**
  - **Solicitantes**

### 3. Página de Categorias (CategoriesPage)

- Lista de categorias de itens disponíveis para empréstimo.
- Busca e filtragem de categorias.
- Ações: criar, editar e excluir categorias.

### 4. Página de Empréstimos (LoansPage)

- Lista de empréstimos ativos.
- Busca e filtragem de empréstimos.
- Ações: criar, editar, finalizar empréstimos.

### 5. Página de Solicitantes (ApplicantsPage)

- Lista de pessoas que podem solicitar empréstimos.
- Busca e filtragem de solicitantes.
- Ações: criar, editar e excluir solicitantes.

---

## Explicação das Principais Páginas

- **SingInPage:** Tela de login, com campos de usuário e senha, acesso ao cadastro e recuperação de senha.
- **SignUpPage:** Tela de cadastro de novo usuário, com validações e feedback visual.
- **ForgotPasswordPage:** Tela para recuperação de senha, solicitando o e-mail do usuário.
- **Layout:** Estrutura principal do app, com navegação por abas.
- **CategoriesPage:** Gerenciamento de categorias de itens ortopédicos.
- **LoansPage:** Gerenciamento dos empréstimos realizados.
- **ApplicantsPage:** Gerenciamento dos solicitantes cadastrados.

---

## Tecnologias Utilizadas

- Flutter
- Dart
- Gerenciamento de estado com setState
- Integração com API REST

---

## Observações

- O aplicativo possui autenticação e controle de sessão.
- Todas as páginas principais possuem busca e ações CRUD (criar, ler, atualizar, deletar).
- O layout é responsivo e adaptado para diferentes tamanhos de tela.

---

## Como Executar

1. Instale as dependências:
   ```sh
   flutter pub get
   ```
2. Execute o app:
   ```sh
   flutter run
   ```

---

## Contato

Desenvolvido por WesleyDev184.
