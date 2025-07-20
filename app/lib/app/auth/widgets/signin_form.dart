import 'package:app/core/api/auth/controllers/auth_controller.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/widgets/input_field.dart';
import 'package:app/core/widgets/password_field.dart';
import 'package:app/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:routefly/routefly.dart';

class SigninForm extends StatefulWidget {
  const SigninForm({super.key});

  @override
  _SigninFormState createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController emailController;
  late TextEditingController passwordController;

  // Métodos de validação
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

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Senha é obrigatória';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Obtém a instância do AuthController
      final authController = Get.find<AuthController>();

      // Realiza o login
      final result = await authController.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (context.mounted) {
        result.fold(
          (user) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bem-vindo, ${user.name}!'),
                backgroundColor: CustomColors.success,
              ),
            );
          },
          (error) {
            // Erro no login
            debugPrint('Erro no login: $error');
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
      debugPrint('Exceção durante login: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                  "Login",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Entre com sua conta",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

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

                const SizedBox(height: 12),

                // Link esqueci senha
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Routefly.navigate(routePaths.auth.forgotPassword);
                    },
                    child: Text(
                      "Esqueci minha senha",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botão principal
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.logIn, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Link de navegação
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Não tenho uma conta? ",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Routefly.navigate(routePaths.auth.signup),
                      child: Text(
                        "Registre-se",
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
