/// Constantes globais do aplicativo
///
/// Esta classe centraliza todas as constantes utilizadas no aplicativo,
/// facilitando manutenção e garantindo consistência.
class AppConstants {
  // ==================== INFORMAÇÕES DO APP ====================

  /// Nome do aplicativo
  static const String appName = 'Sistema de Gestão Rotary';

  /// Versão do aplicativo
  static const String appVersion = '1.0.0';

  /// Nome da organização
  static const String organizationName = 'Rotary Club';

  // ==================== DIMENSÕES PADRÃO ====================

  /// Altura padrão de botões
  static const double buttonHeight = 54.0;

  /// Altura padrão de campos de input
  static const double inputHeight = 56.0;

  /// Tamanho padrão de avatar pequeno
  static const double avatarSizeSmall = 32.0;

  /// Tamanho padrão de avatar médio
  static const double avatarSizeMedium = 48.0;

  /// Tamanho padrão de avatar grande
  static const double avatarSizeLarge = 80.0;

  /// Tamanho padrão de avatar extra grande
  static const double avatarSizeXLarge = 120.0;

  /// Altura padrão da app bar
  static const double appBarHeight = 56.0;

  /// Altura padrão do bottom navigation
  static const double bottomNavHeight = 80.0;

  // ==================== LIMITES E VALIDAÇÕES ====================

  /// Tamanho mínimo de senha
  static const int passwordMinLength = 6;

  /// Tamanho máximo de caracteres para nome
  static const int nameMaxLength = 50;

  /// Tamanho máximo de caracteres para descrição
  static const int descriptionMaxLength = 500;

  /// Número máximo de itens por página
  static const int itemsPerPage = 20;

  // ==================== DURAÇÕES DE ANIMAÇÃO ====================

  /// Duração padrão de animações rápidas
  static const Duration animationFast = Duration(milliseconds: 200);

  /// Duração padrão de animações normais
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Duração padrão de animações lentas
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Duração de splash screens
  static const Duration splashDuration = Duration(seconds: 2);

  // ==================== BREAKPOINTS RESPONSIVOS ====================

  /// Breakpoint para mobile pequeno
  static const double mobileSmall = 320.0;

  /// Breakpoint para mobile
  static const double mobile = 480.0;

  /// Breakpoint para tablet
  static const double tablet = 768.0;

  /// Breakpoint para desktop
  static const double desktop = 1024.0;

  // ==================== URLS E LINKS ====================

  /// URL do site do Rotary
  static const String rotaryWebsite = 'https://www.rotary.org';

  /// URL para política de privacidade
  static const String privacyPolicyUrl = 'https://exemplo.com/privacy';

  /// URL para termos de uso
  static const String termsOfUseUrl = 'https://exemplo.com/terms';

  /// Email de suporte
  static const String supportEmail = 'suporte@rotary.org';

  // ==================== ASSETS PATHS ====================

  /// Caminho para imagens
  static const String imagesPath = 'assets/images/';

  /// Caminho para ícones
  static const String iconsPath = 'assets/icons/';

  /// Logo do Rotary
  static const String rotaryLogo = '${imagesPath}rotary.svg';

  /// Imagem de background
  static const String backgroundImage = '${imagesPath}bg.jpg';

  /// Imagem placeholder
  static const String placeholderImage = '${imagesPath}placeholder.png';

  // ==================== CHAVES DE STORAGE ====================

  /// Chave para salvar dados do usuário
  static const String userDataKey = 'user_data';

  /// Chave para salvar configurações
  static const String settingsKey = 'app_settings';

  /// Chave para salvar tema
  static const String themeKey = 'theme_mode';

  /// Chave para salvar idioma
  static const String languageKey = 'language';

  // ==================== REGEX PATTERNS ====================

  /// Pattern para validação de email
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  /// Pattern para validação de telefone brasileiro
  static const String phonePattern = r'^\(\d{2}\)\s\d{4,5}-\d{4}$';

  /// Pattern para validação de CPF
  static const String cpfPattern = r'^\d{3}\.\d{3}\.\d{3}-\d{2}$';

  // ==================== MENSAGENS PADRÃO ====================

  /// Mensagem de erro genérica
  static const String genericErrorMessage =
      'Ocorreu um erro inesperado. Tente novamente.';

  /// Mensagem de sucesso genérica
  static const String genericSuccessMessage = 'Operação realizada com sucesso!';

  /// Mensagem de conexão com internet
  static const String noInternetMessage =
      'Verifique sua conexão com a internet.';

  /// Mensagem de campos obrigatórios
  static const String requiredFieldMessage = 'Este campo é obrigatório.';

  /// Mensagem de email inválido
  static const String invalidEmailMessage = 'Digite um email válido.';

  /// Mensagem de senha muito curta
  static const String passwordTooShortMessage =
      'A senha deve ter pelo menos $passwordMinLength caracteres.';

  // ==================== STATUS DE EQUIPAMENTOS ====================

  /// Status: Disponível
  static const String statusAvailable = 'Disponível';

  /// Status: Em uso
  static const String statusInUse = 'Em uso';

  /// Status: Em manutenção
  static const String statusMaintenance = 'Em manutenção';

  /// Status: Reservado
  static const String statusReserved = 'Reservado';

  /// Status: Emprestado
  static const String statusBorrowed = 'Emprestado';

  // ==================== TIPOS DE USUÁRIO ====================

  /// Administrador
  static const String userTypeAdmin = 'admin';

  /// Usuário comum
  static const String userTypeUser = 'user';

  /// Solicitante
  static const String userTypeApplicant = 'applicant';

  /// Beneficiário
  static const String userTypeBeneficiary = 'beneficiary';

  // Construtor privado para evitar instanciação
  AppConstants._();
}
