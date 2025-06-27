# Estrutura de Categoria - Sistema PDT

Este documento mostra como usar todas as funcionalidades criadas para o sistema de gerenciamento de categorias e itens.

## Estrutura Criada

### DTOs (Data Transfer Objects)

- `CreateCategoryDTO` - Para criar nova categoria
- `CreateItemDTO` - Para adicionar item à categoria
- `UpdateCategoryDTO` - Para editar categoria (usando PATCH)
- `CreateLoanDTO` - Para criar empréstimo

### Modelos

- `Category` - Modelo da categoria
- `Item` - Modelo do item
- `User` - Modelo do usuário
- `Loan` - Modelo do empréstimo

### Páginas

1. **AddItemPage** - Adicionar novo item à categoria
2. **EditCategoryPage** - Editar categoria existente
3. **CreateLoanPage** - Criar novo empréstimo
4. **DeleteCategoryPage** - Deletar categoria

## Como Usar

### 1. Adicionar Item

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AddItemPage(
      categoryId: "categoria-id",
      categoryTitle: "Nome da Categoria",
    ),
  ),
);
```

**JSON enviado:**

```json
{
  "serialCode": 12345,
  "stockId": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "imageUrl": "https://example.com/item-image.png"
}
```

### 2. Editar Categoria

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditCategoryPage(
      categoryId: "categoria-id",
      currentTitle: "Título Atual",
      currentAvailable: 10,
      currentInMaintenance: 2,
      currentInUse: 3,
    ),
  ),
);
```

**JSON enviado (PATCH - apenas campos alterados):**

```json
{
  "title": "Updated Stock Title",
  "maintenanceQtd": 5,
  "availableQtd": 10,
  "borrowedQtd": 2
}
```

### 3. Deletar Categoria

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DeleteCategoryPage(
      categoryId: "categoria-id",
      categoryTitle: "Nome da Categoria",
    ),
  ),
);
```

**Parâmetro enviado:** Apenas o `categoryId`

### 4. Criar Empréstimo

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CreateLoanPage(
      categoryId: "categoria-id",
      categoryTitle: "Nome da Categoria",
    ),
  ),
);
```

**JSON enviado:**

```json
{
  "applicantId": "11111111-1111-1111-1111-111111111111",
  "responsibleId": "22222222-2222-2222-2222-222222222222",
  "itemId": "33333333-3333-3333-3333-333333333333",
  "reason": "Loaning item for temporary use"
}
```

## Integração com a Página da Categoria

A página `CategoryPage` já está integrada com todas as ações através do menu de ações (`ActionMenuCategory`). Cada botão do menu navega para a página correspondente:

- **Adicionar** → `AddItemPage`
- **Editar** → `EditCategoryPage`
- **Emprestar** → `CreateLoanPage`
- **Deletar** → `DeleteCategoryPage`

## Uso do Result Dart

Todas as operações usam a biblioteca `result_dart` para tratamento de erros:

```dart
final result = await categoryController.createItem(
  createItemDTO: CreateItemDTO(...),
);

result.fold(
  (success) {
    // Ação de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item criado com sucesso!')),
    );
  },
  (error) {
    // Ação de erro
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: ${controller.error}')),
    );
  },
);
```

## Mock Data

O sistema inclui dados simulados para:

- **Itens** - 5 itens por categoria com diferentes status
- **Usuários** - Lista de usuários do sistema
- **Solicitantes** - Usuários que podem fazer empréstimos
- **Responsáveis** - Admins e managers que aprovam empréstimos

## Arquitetura

O sistema segue o padrão:

- **Domain** - Modelos, DTOs e contratos (repositórios abstratos)
- **Data** - Implementações dos repositórios com mock data
- **Presentation** - Controllers, páginas e widgets

Todas as operações são assíncronas e incluem delays simulados para melhor experiência do usuário.
