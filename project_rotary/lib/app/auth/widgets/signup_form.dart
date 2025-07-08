import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/auth/auth_service.dart';
import 'package:project_rotary/core/api/auth/models/auth_models.dart';
import 'package:project_rotary/core/api/orthopedic_banks/orthopedic_banks_service.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/components/password_field.dart';
import 'package:project_rotary/core/components/select_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  String? selectedOrthopedicBankId;
  List<DropdownMenuItem<String>> orthopedicBankItems = [];
  bool isLoadingBanks = false;

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
    });

    try {
      // Verifica se o serviço está inicializado
      if (!OrthopedicBanksService.isInitialized) {
        // Se não estiver inicializado, tenta inicializar
        try {
          // Cria um ApiClient para o serviço
          final apiClient = ApiClient();
          await OrthopedicBanksService.initialize(apiClient: apiClient);
        } catch (e) {
          // Se falhar na inicialização, usa dados padrão
          setState(() {
            _setDefaultBanks();
            isLoadingBanks = false;
          });
          return;
        }
      }

      final orthopedicBanksController = OrthopedicBanksService.instance;
      if (orthopedicBanksController != null) {
        // Buscar bancos ortopédicos da API
        final result = await orthopedicBanksController.loadOrthopedicBanks();

        result.fold(
          (banks) {
            setState(() {
              orthopedicBankItems =
                  banks.map((bank) {
                    return DropdownMenuItem<String>(
                      value: bank.id,
                      child: Text('${bank.name} - ${bank.city}'),
                    );
                  }).toList();
              isLoadingBanks = false;
            });
          },
          (error) {
            setState(() {
              _setDefaultBanks();
              isLoadingBanks = false;
            });
          },
        );
      } else {
        setState(() {
          _setDefaultBanks();
          isLoadingBanks = false;
        });
      }
    } catch (e) {
      setState(() {
        _setDefaultBanks();
        isLoadingBanks = false;
      });
    }
  }

  // Método para definir bancos padrão
  void _setDefaultBanks() {
    orthopedicBankItems = [
      const DropdownMenuItem<String>(
        value: '1',
        child: Text('Banco Ortopédico Central - São Paulo'),
      ),
      const DropdownMenuItem<String>(
        value: '2',
        child: Text('Instituto de Ortopedia - Rio de Janeiro'),
      ),
      const DropdownMenuItem<String>(
        value: '3',
        child: Text('Centro Ortopédico Belo Horizonte - Belo Horizonte'),
      ),
      const DropdownMenuItem<String>(
        value: '4',
        child: Text('Clínica Ortopédica Norte - Brasília'),
      ),
      const DropdownMenuItem<String>(
        value: '5',
        child: Text('Hospital Ortopédico Sul - Porto Alegre'),
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
        color: Colors.white,
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
                  hint:
                      isLoadingBanks
                          ? 'Carregando bancos ortopédicos...'
                          : 'Selecione um banco ortopédico',
                  icon: LucideIcons.building2,
                  items: orthopedicBankItems,
                  onChanged:
                      isLoadingBanks
                          ? null
                          : (value) {
                            setState(() {
                              selectedOrthopedicBankId = value;
                            });
                          },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecione um banco ortopédico';
                    }
                    return null;
                  },
                ),

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
                  onPressed: () async {
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
                    if (passwordController.text !=
                        confirmPasswordController.text) {
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
                            content: Text(
                              'Erro: Serviço de autenticação não inicializado',
                            ),
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
                      final result = await authController.createUser(
                        createUserRequest,
                      );

                      if (context.mounted) {
                        result.fold(
                          (success) {
                            // Usuário criado com sucesso, agora faz login
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Conta criada com sucesso! Fazendo login...',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Faz login automático após criar a conta
                            authController
                                .login(
                                  emailController.text.trim(),
                                  passwordController.text,
                                )
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                            content: Text('Erro inesperado: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
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
                      onTap: () => Navigator.pop(context),
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
