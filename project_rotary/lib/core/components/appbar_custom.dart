import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/auth/di/auth_dependency_factory.dart';
import 'package:project_rotary/app/pdt/info/presentation/pages/info_page.dart';
import 'package:project_rotary/core/components/button.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

const _primaryBg = CustomColors.white;
const _primaryColor = CustomColors.textPrimary;

class AppBarCustom extends StatefulWidget implements PreferredSizeWidget {
  const AppBarCustom({super.key, required this.title});

  final String title;

  @override
  State<AppBarCustom> createState() => _AppBarCustomState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarCustomState extends State<AppBarCustom> {
  final authController = AuthDependencyFactory.instance.authController;
  bool _hasLoadedUserData = false;

  @override
  void initState() {
    super.initState();
    // Carrega os dados do usuário atual apenas uma vez
    _loadUserDataOnce();
  }

  Future<void> _loadUserDataOnce() async {
    // Evita múltiplas chamadas se já carregou ou já tem usuário em cache
    if (_hasLoadedUserData || authController.currentUser != null) {
      return;
    }

    // Evita também se já está carregando
    if (authController.isLoading) {
      return;
    }

    _hasLoadedUserData = true;

    try {
      debugPrint('AppBar - Iniciando carregamento de dados do usuário...');

      // Carrega os dados do usuário atual (que já inclui o banco ortopédico)
      final userResult = await authController.getCurrentUser();
      userResult.fold(
        (user) => debugPrint(
          'AppBar - Usuário carregado: ${user.name} (${user.email}), Banco: ${user.orthopedicBank?.name}',
        ),
        (error) => debugPrint('AppBar - Erro ao carregar usuário: $error'),
      );

      debugPrint('AppBar - Carregamento concluído');
    } catch (e) {
      debugPrint('AppBar - Erro geral ao carregar dados: $e');
    }
  }

  Future<void> _handleLogout() async {
    // Mostra um dialog de confirmação
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar logout'),
            content: const Text('Tem certeza que deseja sair?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sair'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      final result = await authController.logout();

      if (mounted) {
        result.fold(
          (success) {
            // Logout bem-sucedido, navega para a tela de login
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamedAndRemoveUntil('/', (route) => false);
          },
          (error) {
            // Mostra erro se houver falha no logout
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao fazer logout: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _primaryBg,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: _primaryBg,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 8, top: 8, left: 8, right: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 12,
              children: [
                Navigator.canPop(context)
                    ? IconButton(
                      icon: Icon(LucideIcons.arrowLeft, color: _primaryColor),
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                    )
                    : IconButton(
                      icon: Icon(LucideIcons.info),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => InfoPage()));
                      },
                      color: _primaryColor,
                    ),

                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 21,
                    color: _primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                IconButton(
                  icon: Icon(LucideIcons.menu),
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel:
                          MaterialLocalizations.of(
                            context,
                          ).modalBarrierDismissLabel,
                      barrierColor: Colors.black54,
                      transitionDuration: Duration(milliseconds: 300),
                      pageBuilder: (
                        BuildContext buildContext,
                        Animation animation,
                        Animation secondaryAnimation,
                      ) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height,
                            color: _primaryBg,
                            child: Drawer(
                              elevation: 12,
                              child: Column(
                                children: [
                                  Container(
                                    color: CustomColors.background,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ), // opcional
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/images/rotary.svg',
                                        width: 150,
                                      ),
                                    ),
                                  ),

                                  AnimatedBuilder(
                                    animation: authController,
                                    builder: (context, child) {
                                      final user = authController.currentUser;
                                      final isLoading =
                                          authController.isLoading;
                                      final error = authController.error;

                                      // Debug: Log do estado atual
                                      debugPrint(
                                        'AppBar - User: ${user?.name}, Email: ${user?.email}',
                                      );
                                      debugPrint(
                                        'AppBar - Loading: $isLoading, Error: $error',
                                      );

                                      // Se está carregando, mostra indicador
                                      if (isLoading && user == null) {
                                        return const Column(
                                          children: [
                                            ListTile(
                                              leading:
                                                  CircularProgressIndicator(),
                                              title: Text(
                                                'Carregando dados do usuário...',
                                              ),
                                            ),
                                            Divider(),
                                          ],
                                        );
                                      }

                                      // Se houve erro e não há usuário, mostra erro
                                      if (error != null && user == null) {
                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.error,
                                                color: Colors.red,
                                              ),
                                              title: Text(
                                                'Erro ao carregar dados',
                                              ),
                                              subtitle: Text(error),
                                            ),
                                            Divider(),
                                          ],
                                        );
                                      }

                                      // Mostra dados do usuário
                                      return Column(
                                        children: [
                                          ListTile(
                                            leading: Icon(
                                              LucideIcons.idCard,
                                              color: CustomColors.textPrimary,
                                            ),
                                            title: Text(
                                              user?.name ??
                                                  'Nome não disponível',
                                            ),
                                          ),

                                          Divider(),
                                          ListTile(
                                            leading: Icon(
                                              LucideIcons.mail,
                                              color: CustomColors.textPrimary,
                                            ),
                                            title: Text(
                                              user?.email ??
                                                  'Email não disponível',
                                            ),
                                          ),

                                          Divider(),
                                          ListTile(
                                            leading: Icon(
                                              LucideIcons.phone,
                                              color: CustomColors.textPrimary,
                                            ),
                                            title: Text(
                                              user?.phoneNumber ??
                                                  'Telefone não disponível',
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                  Spacer(),

                                  AnimatedBuilder(
                                    animation: authController,
                                    builder: (context, child) {
                                      final user = authController.currentUser;
                                      final orthopedicBank =
                                          user?.orthopedicBank;

                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            LucideIcons.building2,
                                            color: CustomColors.primary,
                                          ),
                                          title: Text(
                                            orthopedicBank?.name ??
                                                'Banco não carregado',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            orthopedicBank?.city ??
                                                (user != null
                                                    ? 'ID: ${user.orthopedicBankId}'
                                                    : ''),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  Button(
                                    text: "Sair",
                                    icon: Icon(
                                      LucideIcons.logOut,
                                      color: CustomColors.white,
                                    ),
                                    backgroundColor: CustomColors.error,
                                    onPressed: _handleLogout,
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 16.0,
                                      bottom: 16.0,
                                    ),
                                    child: Text(
                                      'Versão 1.0.0',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      transitionBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(1, 0),
                            end: Offset(0, 0),
                          ).animate(animation),
                          child: child,
                        );
                      },
                    );
                  },
                  color: _primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
