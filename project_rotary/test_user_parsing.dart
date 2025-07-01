import 'package:project_rotary/app/auth/domain/entities/user.dart';

void main() {
  // Testa o parsing de um usuário com banco ortopédico
  final userJson = {
    'id': '123',
    'name': 'João Silva',
    'email': 'joao@example.com',
    'phoneNumber': '(11) 99999-9999',
    'orthopedicBankId': 'bank_123',
    'orthopedicBank': {
      'id': 'bank_123',
      'name': 'Banco Ortopédico Central',
      'city': 'São Paulo',
      'createdAt': '2024-01-01T10:00:00.000Z',
    },
    'createdAt': '2024-01-01T10:00:00.000Z',
  };

  try {
    final user = User.fromMap(userJson);
    print('✅ Usuário parseado com sucesso:');
    print('Nome: ${user.name}');
    print('Email: ${user.email}');
    print('Banco Ortopédico: ${user.orthopedicBank?.name}');
    print('Cidade do Banco: ${user.orthopedicBank?.city}');
    print('ID do Banco: ${user.orthopedicBankId}');
    print(
      'Banco dentro do usuário: ${user.orthopedicBank != null ? "✅" : "❌"}',
    );
  } catch (e) {
    print('❌ Erro ao parsear usuário: $e');
  }

  // Testa o parsing de um usuário SEM banco ortopédico
  final userJsonWithoutBank = {
    'id': '456',
    'name': 'Maria Santos',
    'email': 'maria@example.com',
    'phoneNumber': '(11) 88888-8888',
    'orthopedicBankId': 'bank_456',
    'createdAt': '2024-01-01T10:00:00.000Z',
  };

  try {
    final user2 = User.fromMap(userJsonWithoutBank);
    print('\n✅ Usuário sem banco parseado com sucesso:');
    print('Nome: ${user2.name}');
    print('Email: ${user2.email}');
    print('Banco Ortopédico: ${user2.orthopedicBank?.name ?? "null"}');
    print('ID do Banco: ${user2.orthopedicBankId}');
    print(
      'Banco dentro do usuário: ${user2.orthopedicBank != null ? "✅" : "❌ (esperado)"}',
    );
  } catch (e) {
    print('❌ Erro ao parsear usuário sem banco: $e');
  }
}
