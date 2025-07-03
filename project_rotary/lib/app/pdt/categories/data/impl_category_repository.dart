import 'package:flutter/widgets.dart';
import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_loan_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_loan_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/category.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/user.dart';
import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/api_config.dart';
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
  final ApiClient _apiClient;

  ImplCategoryRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();
  @override
  AsyncResult<Category> createCategory({
    required CreateCategoryDTO createCategoryDTO,
  }) async {
    try {
      debugPrint(
        'Criando categoria: ${createCategoryDTO.title} para banco: ${createCategoryDTO.orthopedicBankId}',
      );

      // Validação local antes de enviar para API
      if (!createCategoryDTO.isValid) {
        return Failure(Exception('Dados inválidos para criação da categoria'));
      }

      // Chamada para POST /stocks conforme documentação OpenAPI
      final result = await _apiClient.post(ApiEndpoints.stocks, {
        'title': createCategoryDTO.title,
        'orthopedicBankId': createCategoryDTO.orthopedicBankId,
      });

      return result.fold(
        (data) {
          debugPrint('Categoria criada com sucesso: $data');

          // Parse da resposta da API
          final categoryData = data['data'] as Map<String, dynamic>? ?? data;

          // Transformar resposta do stock em Category
          final category = Category.fromJson({
            'id': categoryData['id']?.toString() ?? '',
            'title': categoryData['title'] ?? createCategoryDTO.title,
            'orthopedicBank': {
              'id': createCategoryDTO.orthopedicBankId,
              'name':
                  'Banco Ortopédico', // Nome será obtido em implementação futura
            },
            'createdAt':
                categoryData['createdAt'] ?? DateTime.now().toIso8601String(),
            'updatedAt': categoryData['updatedAt'],
            'imageUrl': categoryData['imageUrl'] ?? 'assets/images/cr.jpg',
            'availableQtd': categoryData['availableQtd'] ?? 0,
            'borrowedQtd': categoryData['borrowedQtd'] ?? 0,
            'maintenanceQtd': categoryData['maintenanceQtd'] ?? 0,
          });

          debugPrint(
            'Categoria parseada: ${category.title} (ID: ${category.id})',
          );
          return Success(category);
        },
        (error) {
          debugPrint('Erro ao criar categoria: $error');
          return Failure(
            Exception('Erro ao criar categoria: ${error.toString()}'),
          );
        },
      );
    } catch (e) {
      debugPrint('Erro inesperado ao criar categoria: $e');
      return Failure(
        Exception('Erro inesperado ao criar categoria: ${e.toString()}'),
      );
    }
  }

  @override
  AsyncResult<List<Category>> getCategories() async {
    try {
      // Implementação mock mantida para compatibilidade
      await Future.delayed(const Duration(seconds: 1));
      return Success([]);
    } catch (e) {
      return Failure(Exception('Erro ao buscar categorias: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<List<Category>> getCategoriesByOrthopedicBank({
    required String orthopedicBankId,
  }) async {
    try {
      debugPrint(
        'Buscando categorias do estoque para orthopedicBankId: $orthopedicBankId',
      );

      // Chamada para GET /stocks/orthopedic-bank/{orthopedicBankId}
      final result = await _apiClient.get(
        ApiEndpoints.stocksByOrthopedicBank(orthopedicBankId),
      );

      return result.fold(
        (data) {
          debugPrint('Dados de estoque retornados: $data');

          // Parse da lista de categorias do estoque
          final stockData =
              data['data'] as List<dynamic>? ?? data as List<dynamic>? ?? [];

          final categories =
              stockData.map((item) {
                final stockItem = item as Map<String, dynamic>;

                // Transformar dados de stock em Category
                // Assumindo que o stock tem estrutura similar à categoria
                return Category.fromJson({
                  'id': stockItem['id']?.toString() ?? '',
                  'title':
                      stockItem['name'] ??
                      stockItem['title'] ??
                      'Categoria sem nome',
                  'orthopedicBank': {
                    'id': orthopedicBankId,
                    'name': 'Banco Ortopédico',
                  },
                  'createdAt':
                      stockItem['createdAt'] ??
                      DateTime.now().toIso8601String(),
                  // Adicionar campos extras que a página espera
                  'imageUrl': stockItem['imageUrl'] ?? 'assets/images/cr.jpg',
                  'availableQtd':
                      stockItem['availableQuantity'] ??
                      stockItem['availableQtd'] ??
                      0,
                  'borrowedQtd':
                      stockItem['borrowedQuantity'] ??
                      stockItem['borrowedQtd'] ??
                      0,
                  'maintenanceQtd':
                      stockItem['maintenanceQuantity'] ??
                      stockItem['maintenanceQtd'] ??
                      0,
                });
              }).toList();

          debugPrint('Categorias parseadas: ${categories.length} itens');
          return Success(categories);
        },
        (error) {
          debugPrint('Erro ao buscar categorias do estoque: $error');
          return Failure(
            Exception(
              'Erro ao buscar categorias do estoque: ${error.toString()}',
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Erro inesperado ao buscar categorias do estoque: $e');
      return Failure(
        Exception(
          'Erro inesperado ao buscar categorias do estoque: ${e.toString()}',
        ),
      );
    }
  }

  @override
  AsyncResult<Category> getCategoryById({required String id}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Implementar busca por ID
    return Failure(Exception('Categoria não encontrada'));
  }

  @override
  AsyncResult<String> deleteCategory({required String id}) async {
    try {
      debugPrint('CategoryRepository: Deletando categoria $id via API');

      // Chama DELETE /stocks/{id}
      final result = await _apiClient.delete(
        ApiEndpoints.stockById(id),
        useAuth: true,
      );

      return result.fold(
        (data) {
          debugPrint('CategoryRepository: Resposta da deleção: $data');

          if (data['success'] == true) {
            final message = data['message'] ?? 'Categoria deletada com sucesso';
            debugPrint('CategoryRepository: $message');
            return Success(message);
          } else {
            // Tratamento de diferentes tipos de erro
            final errorMessage = data['message'] ?? 'Erro ao deletar categoria';
            debugPrint(
              'CategoryRepository: Erro ao deletar categoria: $errorMessage',
            );

            // Verificar se é erro de categoria não encontrada
            if (errorMessage.toLowerCase().contains('not found')) {
              return Failure(Exception('Categoria não encontrada'));
            }

            // Verificar se é erro de categoria com itens associados
            if (errorMessage.toLowerCase().contains('associated') ||
                errorMessage.toLowerCase().contains('items')) {
              return Failure(
                Exception(
                  'Não é possível deletar categoria que possui itens associados',
                ),
              );
            }

            return Failure(Exception(errorMessage));
          }
        },
        (error) {
          debugPrint('CategoryRepository: Erro na requisição: $error');

          // Verificar se é erro 404 (categoria não encontrada)
          if (error.toString().contains('404')) {
            return Failure(Exception('Categoria não encontrada'));
          }

          // Verificar se é erro 400 (possível categoria com itens)
          if (error.toString().contains('400')) {
            return Failure(Exception('Não é possível deletar esta categoria'));
          }

          return Failure(
            Exception('Erro ao deletar categoria: ${error.toString()}'),
          );
        },
      );
    } catch (e) {
      debugPrint('CategoryRepository: Erro inesperado: $e');
      return Failure(Exception('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<Category> updateCategory({
    required String id,
    required UpdateCategoryDTO updateCategoryDTO,
  }) async {
    try {
      debugPrint('CategoryRepository: Atualizando categoria $id via API');

      // Verifica se há dados para atualizar
      if (updateCategoryDTO.isEmpty) {
        return Failure(Exception('Nenhum dado para atualizar'));
      }

      final updateData = updateCategoryDTO.toJson();
      debugPrint('CategoryRepository: Dados de atualização: $updateData');

      // Chama PATCH /stocks/{id}
      final result = await _apiClient.patch(
        ApiEndpoints.stockById(id),
        updateData,
        useAuth: true,
      );

      return result.fold(
        (data) {
          debugPrint(
            'CategoryRepository: Categoria atualizada com sucesso: $data',
          );

          // A API pode retornar data: null em caso de sucesso
          if (data['success'] == true) {
            // Se há dados retornados, usar eles; senão criar categoria mock com dados atualizados
            if (data['data'] != null) {
              final categoryData = data['data'] as Map<String, dynamic>;

              // Transformar resposta do stock em Category
              final category = Category.fromJson({
                'id': categoryData['id']?.toString() ?? id,
                'title': categoryData['title'] ?? 'Categoria Atualizada',
                'orthopedicBank': {
                  'id': categoryData['orthopedicBank']?['id'] ?? '',
                  'name':
                      categoryData['orthopedicBank']?['name'] ??
                      'Banco Ortopédico',
                },
                'createdAt':
                    categoryData['createdAt'] ??
                    DateTime.now().toIso8601String(),
                'updatedAt':
                    categoryData['updatedAt'] ??
                    DateTime.now().toIso8601String(),
                'imageUrl': categoryData['imageUrl'] ?? 'assets/images/cr.jpg',
                'availableQtd': categoryData['availableQtd'] ?? 0,
                'borrowedQtd': categoryData['borrowedQtd'] ?? 0,
                'maintenanceQtd': categoryData['maintenanceQtd'] ?? 0,
              });

              return Success(category);
            } else {
              // API retornou sucesso mas sem dados - criar categoria temporária
              debugPrint(
                'CategoryRepository: Categoria atualizada (sem dados retornados)',
              );
              final tempCategory = Category.fromJson({
                'id': id,
                'title': updateCategoryDTO.title ?? 'Categoria Atualizada',
                'orthopedicBank': {'id': '', 'name': 'Banco Ortopédico'},
                'createdAt':
                    DateTime.now()
                        .subtract(const Duration(days: 5))
                        .toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
                'imageUrl': 'assets/images/cr.jpg',
                'availableQtd': updateCategoryDTO.availableQtd ?? 0,
                'borrowedQtd': updateCategoryDTO.borrowedQtd ?? 0,
                'maintenanceQtd': updateCategoryDTO.maintenanceQtd ?? 0,
              });

              return Success(tempCategory);
            }
          } else {
            debugPrint(
              'CategoryRepository: Erro ao atualizar categoria: $data',
            );
            return Failure(
              Exception(data['message'] ?? 'Erro ao atualizar categoria'),
            );
          }
        },
        (error) {
          debugPrint('CategoryRepository: Erro na requisição: $error');
          return Failure(
            Exception('Erro ao atualizar categoria: ${error.toString()}'),
          );
        },
      );
    } catch (e) {
      debugPrint('CategoryRepository: Erro inesperado: $e');
      return Failure(Exception('Erro inesperado: ${e.toString()}'));
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
        'status': 'ativo',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final loan = Loan.fromJson(loanData);
      return Success(loan);
    } catch (e) {
      return Failure(Exception('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<List<Loan>> getLoans() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock loans
      final mockLoans = List.generate(3, (index) {
        return {
          'id': 'loan_${index + 1}',
          'applicantId': '${index + 2}',
          'responsibleId': '${index + 1}',
          'itemId': 'item_${index + 1}',
          'reason': 'Necessidade médica ${index + 1}',
          'status': index == 0 ? 'ativo' : 'finalizado',
          'createdAt':
              DateTime.now()
                  .subtract(Duration(days: index + 1))
                  .toIso8601String(),
        };
      });

      final loans = mockLoans.map((data) => Loan.fromJson(data)).toList();
      return Success(loans);
    } catch (e) {
      return Failure(Exception('Erro ao buscar empréstimos: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<Loan> getLoanById({required String id}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final loanData = {
        'id': id,
        'applicantId': '2',
        'responsibleId': '1',
        'itemId': 'item_1',
        'reason': 'Necessidade médica urgente',
        'status': 'ativo',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      };

      final loan = Loan.fromJson(loanData);
      return Success(loan);
    } catch (e) {
      return Failure(Exception('Erro ao buscar empréstimo: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<Loan> updateLoan({
    required String id,
    required UpdateLoanDTO updateLoanDTO,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Simular possível erro
      if (DateTime.now().millisecond % 10 == 0) {
        return Failure(Exception('Erro ao atualizar empréstimo'));
      }

      final loanData = {
        'id': id,
        'applicantId': updateLoanDTO.applicantId ?? '2',
        'responsibleId': updateLoanDTO.responsibleId ?? '1',
        'itemId': updateLoanDTO.itemId ?? 'item_1',
        'reason': updateLoanDTO.reason ?? 'Necessidade médica',
        'status': updateLoanDTO.status ?? 'ativo',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'returnDate': updateLoanDTO.returnDate?.toIso8601String(),
      };

      final loan = Loan.fromJson(loanData);
      return Success(loan);
    } catch (e) {
      return Failure(Exception('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<String> deleteLoan({required String id}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Simular possível erro
      if (DateTime.now().millisecond % 15 == 0) {
        return Failure(Exception('Erro ao deletar empréstimo'));
      }

      return Success('Empréstimo deletado com sucesso');
    } catch (e) {
      return Failure(Exception('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<List<Loan>> getLoansByApplicant({
    required String applicantId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      // Mock loans by applicant
      final mockLoans = [
        {
          'id': 'loan_applicant_1',
          'applicantId': applicantId,
          'responsibleId': '1',
          'itemId': 'item_1',
          'reason': 'Reabilitação pós-cirúrgica',
          'status': 'ativo',
          'createdAt':
              DateTime.now()
                  .subtract(const Duration(days: 5))
                  .toIso8601String(),
        },
        {
          'id': 'loan_applicant_2',
          'applicantId': applicantId,
          'responsibleId': '3',
          'itemId': 'item_3',
          'reason': 'Fisioterapia domiciliar',
          'status': 'finalizado',
          'createdAt':
              DateTime.now()
                  .subtract(const Duration(days: 15))
                  .toIso8601String(),
          'returnDate':
              DateTime.now()
                  .subtract(const Duration(days: 2))
                  .toIso8601String(),
        },
      ];

      final loans = mockLoans.map((data) => Loan.fromJson(data)).toList();
      return Success(loans);
    } catch (e) {
      return Failure(
        Exception('Erro ao buscar empréstimos do solicitante: ${e.toString()}'),
      );
    }
  }

  @override
  AsyncResult<List<Loan>> getLoansByItem({required String itemId}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      // Mock loans by item
      final mockLoans = [
        {
          'id': 'loan_item_1',
          'applicantId': '2',
          'responsibleId': '1',
          'itemId': itemId,
          'reason': 'Tratamento fisioterapêutico',
          'status': 'ativo',
          'createdAt':
              DateTime.now()
                  .subtract(const Duration(days: 3))
                  .toIso8601String(),
        },
      ];

      final loans = mockLoans.map((data) => Loan.fromJson(data)).toList();
      return Success(loans);
    } catch (e) {
      return Failure(
        Exception('Erro ao buscar empréstimos do item: ${e.toString()}'),
      );
    }
  }
}
