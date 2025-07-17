import 'package:app/core/api/auth/auth_service.dart';
import 'package:app/core/api/auth/models/auth_models.dart';
import 'package:app/core/api/orthopedic_banks/orthopedic_banks_service.dart';
import 'package:app/core/widgets/input_field.dart';
import 'package:app/core/widgets/password_field.dart';
import 'package:app/core/widgets/select_field.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/app.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:routefly/routefly.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  Future<void> _handleSignUp(BuildContext context) async {
    // Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Valida se um banco ortopédico foi selecionado
    if (selectedOrthopedicBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um banco ortopédico'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Valida se as senhas coincidem
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Obtém a instância do AuthController
      final authController = AuthService.instance;
      if (authController == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Serviço de autenticação não inicializado'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Cria a requisição de criação de usuário
      final createUserRequest = CreateUserRequest(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phoneNumber: phoneController.text.trim(),
        orthopedicBankId: selectedOrthopedicBankId!,
      );

      // Cria o usuário
      final result = await authController.createUser(createUserRequest);

      if (context.mounted) {
        result.fold(
          (success) {
            // Usuário criado com sucesso, agora faz login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Conta criada com sucesso! Fazendo login...'),
                backgroundColor: Colors.green,
              ),
            );

            // Faz login automático após criar a conta
            authController
                .login(emailController.text.trim(), passwordController.text)
                .then((loginResult) {
                  if (context.mounted) {
                    loginResult.fold(
                      (user) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/layout',
                          (route) => false,
                        );
                      },
                      (error) {
                        // Conta criada mas login falhou - vai para tela de login
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/signin',
                          (route) => false,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Conta criada! Faça login para continuar.',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                    );
                  }
                });
          },
          (error) {
            // Erro na criação da conta
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: {e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  String? selectedOrthopedicBankId;
  List<DropdownMenuItem<String>> orthopedicBankItems = [];
  bool isLoadingBanks = false;
  bool hasErrorLoadingBanks = false;

  // Métodos de validação
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome completo é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email inválido';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefone é obrigatório';
    }
    final phoneRegex = RegExp(r'^\d{10,11}$');
    final cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Senha deve ter pelo menos uma letra minúscula';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Senha deve ter pelo menos uma letra maiúscula';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Senha deve ter pelo menos um caractere especial';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != passwordController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // Carrega os bancos ortopédicos ao iniciar o formulário
    _loadOrthopedicBanks();
  }

  // Método para carregar bancos ortopédicos
  Future<void> _loadOrthopedicBanks() async {
    if (isLoadingBanks) return;

    setState(() {
      isLoadingBanks = true;
      hasErrorLoadingBanks = false;
    });

    try {
      final result = await OrthopedicBanksService.getOrthopedicBanks();

      result.fold(
        (banks) {
          setState(() {
            orthopedicBankItems = banks.map((bank) {
              return DropdownMenuItem<String>(
                value: bank.id,
                child: Text('${bank.name} - ${bank.city}'),
              );
            }).toList();
            isLoadingBanks = false;
            hasErrorLoadingBanks = false;
          });
        },
        (error) {
          setState(() {
            _setErrorState();
            isLoadingBanks = false;
            hasErrorLoadingBanks = true;
          });
        },
      );
    } catch (e) {
      setState(() {
        _setErrorState();
        isLoadingBanks = false;
        hasErrorLoadingBanks = true;
      });
    }
  }

  // Método para definir estado de erro
  void _setErrorState() {
    orthopedicBankItems = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          'Erro ao carregar bancos ortopédicos',
          style: TextStyle(color: Colors.red[400], fontStyle: FontStyle.italic),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      width: double.infinity,
      decoration: BoxDecoration(
        color: CustomColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, -8),
            spreadRadius: 1,
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicador visual para o card
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Título da seção
                const Text(
                  "Criar conta",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Preencha os dados para se cadastrar",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

                // Campo Nome
                const Text(
                  'Nome completo *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                InputField(
                  controller: nameController,
                  hint: "Digite seu nome completo",
                  icon: LucideIcons.user,
                  validator: _validateName,
                ),

                const SizedBox(height: 16),

                // Campo Email
                const Text(
                  'Email *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                InputField(
                  controller: emailController,
                  hint: "Digite seu email",
                  icon: LucideIcons.mail,
                  validator: _validateEmail,
                ),

                const SizedBox(height: 16),

                // Campo Telefone
                const Text(
                  'Telefone *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                InputField(
                  controller: phoneController,
                  hint: "Digite seu telefone",
                  icon: LucideIcons.phone,
                  mask: InputMask.phone,
                  validator: _validatePhone,
                ),

                const SizedBox(height: 16),

                // Campo Banco Ortopédico
                const Text(
                  'Banco Ortopédico *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                SelectField<String>(
                  value: selectedOrthopedicBankId,
                  hint: isLoadingBanks
                      ? 'Carregando bancos ortopédicos...'
                      : hasErrorLoadingBanks
                      ? 'Erro ao carregar dados'
                      : 'Selecione um banco ortopédico',
                  icon: LucideIcons.building2,
                  items: orthopedicBankItems,
                  onChanged: (isLoadingBanks || hasErrorLoadingBanks)
                      ? null
                      : (value) {
                          setState(() {
                            selectedOrthopedicBankId = value;
                          });
                        },
                  validator: (value) {
                    if (hasErrorLoadingBanks) {
                      return 'Não foi possível carregar os bancos ortopédicos. Tente novamente.';
                    }
                    if (value == null || value.isEmpty) {
                      return 'Selecione um banco ortopédico';
                    }
                    return null;
                  },
                ),

                // Botão para tentar carregar novamente em caso de erro
                if (hasErrorLoadingBanks) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Colors.red[400],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Falha ao carregar bancos ortopédicos',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[400],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadOrthopedicBanks,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Tentar novamente',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Campo Senha
                const Text(
                  'Senha *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                PasswordField(
                  controller: passwordController,
                  hint: "Digite sua senha",
                  validator: _validatePassword,
                ),
                const SizedBox(height: 4),
                Text(
                  'A senha deve ter pelo menos 6 caracteres, uma letra maiúscula, uma minúscula e um caractere especial',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),

                const SizedBox(height: 16),

                // Campo Confirmar Senha
                const Text(
                  'Confirmar senha *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                PasswordField(
                  controller: confirmPasswordController,
                  hint: "Confirme sua senha",
                  validator: _validateConfirmPassword,
                ),

                const SizedBox(height: 20),

                // Botão principal
                ElevatedButton(
                  onPressed: () => _handleSignUp(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Criar conta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Link de navegação
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Já tem uma conta? ",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Routefly.pushNavigate(routePaths.auth.signin),
                      child: Text(
                        "Faça login",
                        style: TextStyle(
                          color: CustomColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
