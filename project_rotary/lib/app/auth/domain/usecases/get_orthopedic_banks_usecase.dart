import 'package:project_rotary/app/auth/domain/auth_repository.dart';
import 'package:project_rotary/app/auth/domain/entities/orthopedic_bank.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para buscar bancos ortopédicos disponíveis.
/// Segue o padrão Clean Architecture implementado em loans, applicants e categories.
class GetOrthopedicBanksUseCase {
  final AuthRepository repository;

  const GetOrthopedicBanksUseCase({required this.repository});

  AsyncResult<List<OrthopedicBank>> call() async {
    try {
      return await repository.getOrthopedicBanks();
    } catch (e) {
      return Failure(
        Exception('Erro ao buscar bancos ortopédicos: ${e.toString()}'),
      );
    }
  }
}
