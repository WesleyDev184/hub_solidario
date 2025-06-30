# Guia de Migração das Páginas Categories

## 📋 Resumo das Mudanças Necessárias

As páginas de categories precisam ser atualizadas para usar a nova arquitetura Clean Architecture implementada. Esta documentação serve como guia para as atualizações necessárias.

## 🔄 Mudanças Principais

### 1. **Dependency Injection**

#### Antes:

```dart
final categoryController = CategoryController(ImplCategoryRepository());
```

#### Depois:

```dart
final categoryController = CategoryDependencyFactory.instance.categoryController;
```

### 2. **Imports Necessários**

#### Adicionar:

```dart
import 'package:project_rotary/app/pdt/categories/di/category_dependency_factory.dart';
```

#### Remover (se não usado diretamente):

```dart
import 'package:project_rotary/app/pdt/categories/data/impl_category_repository.dart';
import 'package:project_rotary/app/pdt/categories/presentation/controller/category_controller.dart';
```

### 3. **Tratamento de Retorno dos Métodos**

#### Antes (o controller retornava Result):

```dart
final result = await categoryController.createCategory(...);

result.fold(
  (success) {
    // Sucesso
  },
  (error) {
    // Erro
  },
);
```

#### Depois (o controller é void e atualiza estado interno):

```dart
await categoryController.createCategory(...);

if (categoryController.errorMessage != null) {
  // Erro
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(categoryController.errorMessage!),
      backgroundColor: Colors.red,
    ),
  );
} else {
  // Sucesso
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Operação realizada com sucesso!'),
      backgroundColor: Colors.green,
    ),
  );
}
```

### 4. **Propriedades do Controller Atualizadas**

#### Antes:

```dart
categoryController.error        // ❌ Não existe mais
categoryController.isLoading    // ❌ Não existe mais
categoryController.categories   // ❌ Não existe mais
```

#### Depois:

```dart
categoryController.errorMessage // ✅ Novo nome
categoryController.isLoading    // ✅ Mesmo nome
categoryController.categories   // ✅ Mesmo nome
```

## 📄 Páginas que Precisam ser Atualizadas

### ✅ **Páginas já corrigidas:**

- `new_category_page.dart` - ✅ Atualizada

### ❌ **Páginas que precisam correção:**

- `add_item_page.dart` - Usar `ItemController` da factory
- `create_loan_page.dart` - Usar `LoanController` da factory
- `delete_category_page.dart` - Usar novo `CategoryController`
- `edit_category_page.dart` - Usar novo `CategoryController`
- `categories_page.dart` - Usar novo `CategoryController`
- `category_page.dart` - Usar novo `CategoryController`

## 🛠️ Controllers Disponíveis na Factory

### CategoryController

```dart
final categoryController = CategoryDependencyFactory.instance.categoryController;
```

**Métodos disponíveis:**

- `createCategory(CreateCategoryDTO)` → void
- `getCategories()` → void
- `getCategoryById(String id)` → void
- `updateCategory(String id, UpdateCategoryDTO)` → void
- `deleteCategory(String id)` → void

**Propriedades:**

- `isLoading` → bool
- `errorMessage` → String?
- `categories` → List<Category>
- `selectedCategory` → Category?

### ItemController

```dart
final itemController = CategoryDependencyFactory.instance.itemController;
```

**Métodos disponíveis:**

- `createItem(CreateItemDTO)` → void
- `getItemsByCategory(String categoryId)` → void
- `getItemById(String id)` → void
- `updateItem(String id, UpdateItemDTO)` → void
- `deleteItem(String id)` → void

**Propriedades:**

- `isLoading` → bool
- `errorMessage` → String?
- `items` → List<Item>
- `selectedItem` → Item?

### LoanController

```dart
final loanController = CategoryDependencyFactory.instance.loanController;
```

**Métodos disponíveis:**

- `createLoan(CreateLoanDTO)` → void
- `getLoans()` → void
- `getLoanById(String id)` → void
- `updateLoan(String id, UpdateLoanDTO)` → void
- `deleteLoan(String id)` → void
- `getLoansByApplicant(String applicantId)` → void
- `getApplicants()` → void
- `getResponsibles()` → void

**Propriedades:**

- `isLoading` → bool
- `errorMessage` → String?
- `loans` → List<Loan>
- `selectedLoan` → Loan?
- `applicants` → List<User>
- `responsibles` → List<User>

## 🎯 Exemplo Completo

### Página para Criar Item (add_item_page.dart)

```dart
import 'package:flutter/material.dart';
import 'package:project_rotary/app/pdt/categories/di/category_dependency_factory.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_item_dto.dart';

class AddItemPage extends StatefulWidget {
  final String categoryId;

  const AddItemPage({super.key, required this.categoryId});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _serialCodeController = TextEditingController();
  final _stockIdController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // Usando a dependency factory
  final itemController = CategoryDependencyFactory.instance.itemController;

  @override
  void dispose() {
    _serialCodeController.dispose();
    _stockIdController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _createItem() async {
    if (!_formKey.currentState!.validate()) return;

    await itemController.createItem(
      createItemDTO: CreateItemDTO(
        categoryId: int.parse(widget.categoryId),
        serialCode: int.parse(_serialCodeController.text),
        stockId: _stockIdController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      ),
    );

    if (mounted) {
      if (itemController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(itemController.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Item')),
      body: ListenableBuilder(
        listenable: itemController,
        builder: (context, _) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _serialCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Código Serial',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Código serial é obrigatório';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Código serial deve ser um número';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _stockIdController,
                        decoration: const InputDecoration(
                          labelText: 'ID do Estoque',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'ID do estoque é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL da Imagem',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'URL da imagem é obrigatória';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: itemController.isLoading ? null : _createItem,
                        child: Text(
                          itemController.isLoading ? 'Criando...' : 'Criar Item'
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (itemController.isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }
}
```

## ⚠️ Pontos de Atenção

1. **ListenableBuilder**: Use `ListenableBuilder` ao invés de `Consumer` para escutar mudanças do controller
2. **Validation**: A validação agora ocorre em múltiplas camadas (DTO → Use Case → Repository)
3. **Error Handling**: Use `categoryController.errorMessage` ao invés de `categoryController.error`
4. **Loading State**: Use `categoryController.isLoading` para mostrar loading
5. **Cleanup**: O factory gerencia o ciclo de vida dos controllers, não precisa dispose manual

---

**✅ Status**: Guia completo para migração das páginas de categories para a nova arquitetura Clean Architecture.
