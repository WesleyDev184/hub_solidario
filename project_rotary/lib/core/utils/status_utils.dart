import 'package:flutter/material.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

/// Utilitários para mapeamento de status de itens
class StatusUtils {
  /// Converte o status do item para texto amigável ao usuário
  static String getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return 'Disponível';
      case 'IN_USE':
        return 'Em uso';
      case 'MAINTENANCE':
        return 'Manutenção';
      case 'LOST':
        return 'Perdido';
      case 'DONATED':
        return 'Doado';
      case 'UNAVAILABLE':
        return 'Indisponível';
      default:
        debugPrint('Status desconhecido: $status');
        return 'Desconhecido';
    }
  }

  /// Retorna a cor correspondente ao status do item
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return CustomColors.success;
      case 'IN_USE':
        return CustomColors.warning;
      case 'MAINTENANCE':
        return CustomColors.error;
      case 'LOST':
        return CustomColors.error;
      case 'DONATED':
        return CustomColors.textSecondary;
      default:
        return CustomColors.textSecondary;
    }
  }

  /// Retorna o ícone correspondente ao status do item
  static IconData getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return Icons.check_circle;
      case 'IN_USE':
        return Icons.access_time;
      case 'MAINTENANCE':
        return Icons.build;
      case 'LOST':
        return Icons.error;
      case 'DONATED':
        return Icons.favorite;
      default:
        return Icons.help;
    }
  }

  /// Verifica se o status indica que o item está disponível
  static bool isAvailable(String status) {
    return status.toUpperCase() == 'AVAILABLE';
  }

  /// Verifica se o status indica que o item está em uso
  static bool isInUse(String status) {
    return status.toUpperCase() == 'IN_USE';
  }

  /// Verifica se o status indica que o item está em manutenção
  static bool isInMaintenance(String status) {
    return status.toUpperCase() == 'MAINTENANCE';
  }

  /// Verifica se o status indica que o item está indisponível
  static bool isUnavailable(String status) {
    final statusUpper = status.toUpperCase();
    return statusUpper == 'LOST' || statusUpper == 'DONATED';
  }
}
