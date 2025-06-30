import 'package:flutter/widgets.dart';
import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_item_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_loan_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/category.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/item.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/loan.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/user.dart';
import 'package:result_dart/result_dart.dart';

// Mock data para bancos ortopédicos
final List<Map<String, dynamic>> orthopedicBanks = [
  {"id": "1", "name": "Banco Ortopédico Central"},
  {"id": "2", "name": "Banco Ortopédico Norte"},
  {"id": "3", "name": "Banco Ortopédico Sul"},
  {"id": "4", "name": "Banco Ortopédico Leste"},
  {"id": "5", "name": "Banco Ortopédico Oeste"},
];

class ImplCategoryRepository implements CategoryRepository {
  @override
  AsyncResult<Category> createCategory({
    required CreateCategoryDTO createCategoryDTO,
  }) async {
    try {
      // Simular delay de API
      await Future.delayed(const Duration(seconds: 2));

      // Simular possível erro (10% de chance)
      if (DateTime.now().millisecond % 10 == 0) {
        return Failure(Exception('Erro no servidor. Tente novamente.'));
      }

      final selectedBank = orthopedicBanks.firstWhere(
        (bank) => bank['id'] == createCategoryDTO.orthopedicBankId,
        orElse: () => throw Exception('Banco ortopédico não encontrado'),
      );

      // Simular validação no backend
      if (createCategoryDTO.title.toLowerCase().contains('teste')) {
        return Failure(Exception('Título não pode conter a palavra "teste"'));
      }

      final categoryData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': createCategoryDTO.title.trim(),
        'orthopedicBank': selectedBank,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final category = Category.fromJson(categoryData);

      debugPrint('Categoria criada com sucesso: ${category.title}');
      return Success(category);
    } catch (e) {
      return Failure(Exception('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<List<Category>> getCategories() async {
    await Future.delayed(const Duration(seconds: 1));
    // Implementar busca de categorias
    return Success([]);
  }

  @override
  AsyncResult<Category> getCategoryById({required String id}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Implementar busca por ID
    return Failure(Exception('Categoria não encontrada'));
  }

  @override
  AsyncResult<String> deleteCategory({required String id}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Implementar exclusão
    return Success('Categoria deletada com sucesso');
  }

  @override
  AsyncResult<Category> updateCategory({
    required String id,
    required UpdateCategoryDTO updateCategoryDTO,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Simular possível erro
      if (DateTime.now().millisecond % 15 == 0) {
        return Failure(Exception('Erro ao atualizar categoria'));
      }

      // Mock data da categoria atualizada
      final categoryData = {
        'id': id,
        'title': updateCategoryDTO.title ?? 'Categoria Atualizada',
        'orthopedicBank': orthopedicBanks.first,
        'createdAt':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'maintenanceQtd': updateCategoryDTO.maintenanceQtd ?? 2,
        'availableQtd': updateCategoryDTO.availableQtd ?? 8,
        'borrowedQtd': updateCategoryDTO.borrowedQtd ?? 3,
      };

      final category = Category.fromJson(categoryData);
      return Success(category);
    } catch (e) {
      return Failure(Exception('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<Item> createItem({required CreateItemDTO createItemDTO}) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Simular possível erro
      if (DateTime.now().millisecond % 12 == 0) {
        return Failure(Exception('Erro ao criar item'));
      }

      final itemData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'serialCode': createItemDTO.serialCode,
        'stockId': createItemDTO.stockId,
        'imageUrl': createItemDTO.imageUrl,
        'status': 'Disponível',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final item = Item.fromJson(itemData);
      return Success(item);
    } catch (e) {
      return Failure(Exception('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<List<Item>> getItemsByCategory({
    required String categoryId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock items para a categoria
      final mockItems = List.generate(5, (index) {
        final statuses = ['Disponível', 'Em manutenção', 'Emprestado'];
        return {
          'id': '${categoryId}_item_${index + 1}',
          'serialCode': 10000 + index,
          'stockId': categoryId,
          'imageUrl': 'https://example.com/item${index + 1}.png',
          'status': statuses[index % statuses.length],
          'createdAt':
              DateTime.now().subtract(Duration(days: index)).toIso8601String(),
        };
      });

      final items = mockItems.map((data) => Item.fromJson(data)).toList();
      return Success(items);
    } catch (e) {
      return Failure(Exception('Erro ao buscar itens: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<List<User>> getUsers() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock users
      final mockUsers = [
        {
          'id': '1',
          'name': 'João Silva',
          'email': 'joao@example.com',
          'role': 'admin',
        },
        {
          'id': '2',
          'name': 'Maria Santos',
          'email': 'maria@example.com',
          'role': 'user',
        },
        {
          'id': '3',
          'name': 'Pedro Costa',
          'email': 'pedro@example.com',
          'role': 'manager',
        },
        {
          'id': '4',
          'name': 'Ana Lima',
          'email': 'ana@example.com',
          'role': 'user',
        },
        {
          'id': '5',
          'name': 'Carlos Ferreira',
          'email': 'carlos@example.com',
          'role': 'admin',
        },
      ];

      final users = mockUsers.map((data) => User.fromJson(data)).toList();
      return Success(users);
    } catch (e) {
      return Failure(Exception('Erro ao buscar usuários: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<List<User>> getApplicants() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock applicants (users que podem solicitar empréstimos)
      final mockApplicants = [
        {
          'id': '2',
          'name': 'Maria Santos',
          'email': 'maria@example.com',
          'role': 'user',
        },
        {
          'id': '4',
          'name': 'Ana Lima',
          'email': 'ana@example.com',
          'role': 'user',
        },
        {
          'id': '6',
          'name': 'Roberto Silva',
          'email': 'roberto@example.com',
          'role': 'user',
        },
      ];

      final applicants =
          mockApplicants.map((data) => User.fromJson(data)).toList();
      return Success(applicants);
    } catch (e) {
      return Failure(Exception('Erro ao buscar solicitantes: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<List<User>> getResponsibles() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock responsibles (admins e managers)
      final mockResponsibles = [
        {
          'id': '1',
          'name': 'João Silva',
          'email': 'joao@example.com',
          'role': 'admin',
        },
        {
          'id': '3',
          'name': 'Pedro Costa',
          'email': 'pedro@example.com',
          'role': 'manager',
        },
        {
          'id': '5',
          'name': 'Carlos Ferreira',
          'email': 'carlos@example.com',
          'role': 'admin',
        },
      ];

      final responsibles =
          mockResponsibles.map((data) => User.fromJson(data)).toList();
      return Success(responsibles);
    } catch (e) {
      return Failure(Exception('Erro ao buscar responsáveis: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<Loan> createLoan({required CreateLoanDTO createLoanDTO}) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Simular possível erro
      if (DateTime.now().millisecond % 8 == 0) {
        return Failure(Exception('Erro ao criar empréstimo'));
      }

      final loanData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'applicantId': createLoanDTO.applicantId,
        'responsibleId': createLoanDTO.responsibleId,
        'itemId': createLoanDTO.itemId,
        'reason': createLoanDTO.reason,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final loan = Loan.fromJson(loanData);
      return Success(loan);
    } catch (e) {
      return Failure(Exception('Erro inesperado: ${e.toString()}'));
    }
  }
}
