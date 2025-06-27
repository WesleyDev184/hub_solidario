# 🌟 Sistema de Gestão Rotary

Um aplicativo Flutter desenvolvido para gerenciar empréstimos de equipamentos ortopédicos e assistivos em bancos ortopédicos associados ao Rotary Club.

## 📱 Sobre o Projeto

O **Sistema de Gestão Rotary** é uma solução mobile para digitalizar e otimizar o processo de empréstimo de equipamentos médicos, conectando solicitantes, beneficiários e responsáveis pelos bancos ortopédicos de forma eficiente e organizada.

## 🏗️ Arquitetura

O projeto segue os princípios da **Clean Architecture** com uma estrutura bem definida de camadas:

### 📁 Estrutura de Pastas

```
lib/
├── app/                          # Camada de aplicação
│   ├── auth/                     # Módulo de autenticação
│   │   ├── data/                 # Camada de dados
│   │   ├── domain/               # Camada de domínio
│   │   └── presentation/         # Camada de apresentação
│   └── pdt/                      # Módulo principal do sistema
│       ├── applicants/           # Gestão de solicitantes
│       ├── categories/           # Gestão de categorias e itens
│       ├── info/                 # Informações do sistema
│       ├── loans/                # Gestão de empréstimos
│       └── layout.dart           # Layout principal da aplicação
├── core/                         # Componentes e recursos compartilhados
│   ├── components/               # Componentes UI reutilizáveis
│   └── theme/                    # Definições de tema
└── main.dart                     # Ponto de entrada da aplicação
```

### 🏛️ Camadas da Arquitetura

#### **Presentation Layer**

- **Controllers**: Gerenciam o estado da aplicação usando `ChangeNotifier`
- **Pages**: Telas principais da aplicação
- **Widgets**: Componentes UI específicos de cada módulo

#### **Domain Layer**

- **Models**: Entidades de domínio (`User`, `Category`, `Item`, `Loan`)
- **DTOs**: Objetos de transferência de dados
- **Repositories**: Interfaces dos repositórios (abstrações)

#### **Data Layer**

- **Implementations**: Implementações concretas dos repositórios
- Integração com APIs e fontes de dados externas

## ✨ Funcionalidades

### 🔐 **Autenticação**

- Login de usuários
- Cadastro de novos usuários
- Gerenciamento de sessão

### 📋 **Gestão de Categorias**

- Criação, edição e exclusão de categorias de equipamentos
- Visualização de status (disponível, em uso, manutenção)
- Associação com bancos ortopédicos

### 🛠️ **Gestão de Itens**

- Adição de novos equipamentos por categoria
- Controle de código serial único
- Gerenciamento de status dos equipamentos

### 👥 **Gestão de Solicitantes**

- Cadastro de solicitantes e beneficiários
- Visualização de perfis completos
- Histórico de empréstimos

### 📝 **Sistema de Empréstimos**

- Criação de novos empréstimos
- Associação entre item, solicitante e responsável
- Controle de datas de devolução
- Acompanhamento de status

### ℹ️ **Informações**

- Página de créditos e informações do desenvolvedor
- Informações de contato e versão

## 🎨 Design System

### **Paleta de Cores**

- **Primary**: `Color(0xFF451A7D)` - Roxo característico do Rotary
- **Background**: `Color(0xFFF6F5F5)` - Cinza claro
- **Success**: `Color(0xFF0BCE83)` - Verde para ações positivas
- **Error**: `Color(0xFFFF5151)` - Vermelho para alertas
- **Warning**: `Color(0xFFD9C96F)` - Amarelo para avisos

### **Componentes Reutilizáveis**

- `AppBarCustom`: Barra de navegação personalizada
- `Button`: Botões padronizados
- `InputField`: Campos de entrada
- `PasswordField`: Campo de senha
- `SelectField`: Campo de seleção
- `Avatar`: Componente de avatar
- `InfoRow`: Linha de informação
- `BackgroundWrapper`: Wrapper para backgrounds

## 📦 Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_svg: ^2.0.17 # Suporte a SVG
  result_dart: ^2.1.0 # Tratamento funcional de resultados
  lucide_icons_flutter: ^3.0.3 # Ícones modernos
  flutter_staggered_animations: ^1.1.1 # Animações escalonadas
  url_launcher: ^6.3.1 # Abertura de URLs

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0 # Análise de código
```

## 📊 Modelos de Dados

### **User**

```dart
class User {
  final String id;
  final String name;
  final String email;
  final String role;
}
```

### **Category**

```dart
class Category {
  final String id;
  final String title;
  final Map<String, dynamic> orthopedicBank;
  final String createdAt;
}
```

### **Item**

```dart
class Item {
  final String id;
  final int serialCode;
  final String stockId;
  final String imageUrl;
  final String status;
  final DateTime createdAt;
}
```

### **Loan**

```dart
class Loan {
  final String id;
  final String itemId;
  final String applicantId;
  final String responsibleId;
  final String reason;
  final DateTime createdAt;
  final DateTime? returnDate;
  final String status;
}
```

## 🚀 Como Executar

### **Pré-requisitos**

- Flutter SDK (versão 3.7.2+)
- Dart SDK
- Android Studio / VS Code
- Emulador Android ou dispositivo físico

## 🗂️ Navegação

O aplicativo utiliza um sistema de navegação baseado em abas:

1. **Categorias** - Gestão de categorias e itens
2. **Empréstimos** - Controle de empréstimos ativos
3. **Solicitantes** - Gestão de usuários solicitantes

### **Rotas Principais**

- `/` - Tela de login
- `/signup` - Tela de cadastro
- `/layout` - Layout principal com navegação por abas

## 🔄 Fluxo de Uso

1. **Login/Cadastro**: Usuário acessa o sistema
2. **Navegação**: Escolhe entre categorias, empréstimos ou solicitantes
3. **Gestão de Categorias**: Cria categorias e adiciona itens
4. **Criação de Empréstimos**: Associa itens a solicitantes
5. **Acompanhamento**: Monitora status dos empréstimos

## 🎯 Estado dos Itens

- **Disponível**: Item disponível para empréstimo
- **Emprestado**: Item atualmente emprestado
- **Em Manutenção**: Item em processo de manutenção

## 👨‍💻 Desenvolvimento

### **Padrões Utilizados**

- **Clean Architecture**: Separação clara de responsabilidades
- **Repository Pattern**: Abstração da camada de dados
- **Controller Pattern**: Gerenciamento de estado com `ChangeNotifier`
- **DTO Pattern**: Transferência segura de dados entre camadas

### **Estrutura de Controladores**

```dart
class CategoryController extends ChangeNotifier {
  final CategoryRepository _categoryRepository;

  bool isLoading = false;
  String? error;
  List<Category> categories = [];

  // Métodos de negócio...
}
```

## 📱 Compatibilidade

- **Android**: API 21+ (Android 5.0)
- **iOS**: iOS 11.0+
- **Orientação**: Portrait (modo retrato)

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Contato

**Desenvolvedor**: Wesley Antonio  
**LinkedIn**: [wesleyantonio](https://www.linkedin.com/in/wesleyantonio)

---

_Desenvolvido com ❤️ para otimizar a gestão de bancos ortopédicos do Rotary Club_
