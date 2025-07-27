import 'package:intl/intl.dart';

/// Utilitários para formatação de datas
class DateUtils {
  /// Formata uma data para o formato brasileiro (dd/MM/yyyy)
  static String formatDateBR(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formata uma data para o formato brasileiro com hora (dd/MM/yyyy HH:mm)
  static String formatDateTimeBR(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Formata uma data para exibição relativa (ex: "hoje", "ontem", "há 2 dias")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dias';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'Há 1 semana' : 'Há $weeks semanas';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'Há 1 mês' : 'Há $months meses';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'Há 1 ano' : 'Há $years anos';
    }
  }

  /// Formata uma data para exibição no formato "dd MMM yyyy" (ex: "15 Jan 2025")
  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM yyyy', 'pt_BR').format(date);
  }

  /// Verifica se duas datas são do mesmo dia
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Retorna o início do dia para uma data
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Retorna o fim do dia para uma data
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}
