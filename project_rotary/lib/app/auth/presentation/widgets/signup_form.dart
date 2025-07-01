import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/auth/di/auth_dependency_factory.dart';
import 'package:project_rotary/app/auth/domain/dto/signup_dto.dart';
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
  final authController = AuthDependencyFactory.instance.authController;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  String? selectedOrthopedicBankId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // Carrega os bancos ortopédicos disponíveis
    authController.getOrthopedicBanks();
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
              AnimatedBuilder(
                animation: authController,
                builder: (context, child) {
                  if (authController.isLoading &&
                      authController.orthopedicBanks.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Carregando bancos ortopédicos...'),
                        ],
                      ),
                    );
                  }

                  return SelectField<String>(
                    value: selectedOrthopedicBankId,
                    hint: 'Selecione um banco ortopédico',
                    icon: LucideIcons.building2,
                    items:
                        authController.orthopedicBanks.map((bank) {
                          return DropdownMenuItem<String>(
                            value: bank.id,
                            child: Text('${bank.name} - ${bank.city}'),
                          );
                        }).toList(),
                    onChanged: (value) {
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
                  );
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
              ),

              const SizedBox(height: 20),

              // Botão principal
              ElevatedButton(
                onPressed: () async {
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

                  final result = await authController.signup(
                    signUpDTO: SignUpDTO(
                      email: emailController.text,
                      password: passwordController.text,
                      confirmPassword: confirmPasswordController.text,
                      name: nameController.text,
                      phoneNumber: phoneController.text,
                      orthopedicBankId: selectedOrthopedicBankId!,
                    ),
                  );

                  if (context.mounted) {
                    result.fold(
                      (user) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/layout',
                          (route) => false,
                        );
                      },
                      (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              authController.error ?? 'Erro ao criar conta',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    );
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
    );
  }
}
