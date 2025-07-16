import 'package:app/core/api/auth/auth_service.dart';
import 'package:app/core/components/button.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:routefly/routefly.dart';

const _primaryBg = CustomColors.white;
const _primaryColor = CustomColors.textPrimary;

class AppBarCustom extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? path;
  final bool initialRoute;

  const AppBarCustom({
    super.key,
    required this.title,
    this.path,
    this.initialRoute = false,
  });

  @override
  State<AppBarCustom> createState() => _AppBarCustomState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarCustomState extends State<AppBarCustom> {
  Future<void> _handleLogout() async {
    // Mostra um dialog de confirmação
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar logout'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Routefly.pop(context, result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Routefly.pop(context, result: true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      try {
        // Obtém a instância do AuthController
        final authController = AuthService.instance;
        if (authController != null) {
          // Realiza o logout
          await authController.logout();
        }

        // Navega para a tela de login
        if (mounted) {
          Routefly.pushNavigate(routePaths.auth.signin);
        }
      } catch (e) {
        // Em caso de erro, ainda assim navega para a tela de login
        if (mounted) {
          Routefly.pushNavigate(routePaths.auth.signin);
        }
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SizedBox(
              height: kToolbarHeight - 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ícone à esquerda
                  !widget.initialRoute
                      ? IconButton(
                          icon: Icon(
                            LucideIcons.arrowLeft,
                            color: _primaryColor,
                          ),
                          onPressed: () {
                            if (widget.path != null &&
                                widget.path!.isNotEmpty) {
                              Routefly.pushNavigate(widget.path!);
                            } else {
                              Routefly.pop(context);
                            }
                          },
                        )
                      : IconButton(
                          icon: Icon(LucideIcons.info),
                          onPressed: () {
                            Routefly.pushNavigate(routePaths.info);
                          },
                          color: _primaryColor,
                        ),
                  // Espaço pequeno
                  const SizedBox(width: 4),
                  // Título centralizado, ocupa o espaço restante
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 21,
                          color: _primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Espaço pequeno
                  const SizedBox(width: 4),
                  // Ícone à direita
                  IconButton(
                    icon: Icon(LucideIcons.menu),
                    onPressed: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(
                          context,
                        ).modalBarrierDismissLabel,
                        barrierColor: Colors.black54,
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder:
                            (
                              BuildContext buildContext,
                              Animation animation,
                              Animation secondaryAnimation,
                            ) {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
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
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/images/rotary.svg',
                                              width: 150,
                                            ),
                                          ),
                                        ),
                                        // ...existing code...
                                        Builder(
                                          builder: (context) {
                                            final authController =
                                                AuthService.instance;
                                            final user =
                                                authController?.currentUser;
                                            return Column(
                                              children: [
                                                ListTile(
                                                  leading: Icon(
                                                    LucideIcons.idCard,
                                                    color: CustomColors
                                                        .textPrimary,
                                                  ),
                                                  title: Text(
                                                    user?.name ??
                                                        'Nome não disponível',
                                                  ),
                                                ),
                                                const Divider(),
                                                ListTile(
                                                  leading: Icon(
                                                    LucideIcons.mail,
                                                    color: CustomColors
                                                        .textPrimary,
                                                  ),
                                                  title: Text(
                                                    user?.email ??
                                                        'Email não disponível',
                                                  ),
                                                ),
                                                const Divider(),
                                                ListTile(
                                                  leading: Icon(
                                                    LucideIcons.phone,
                                                    color: CustomColors
                                                        .textPrimary,
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
                                        const Spacer(),
                                        Builder(
                                          builder: (context) {
                                            final authController =
                                                AuthService.instance;
                                            final user =
                                                authController?.currentUser;
                                            final orthopedicBank =
                                                user?.orthopedicBank;
                                            return Card(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              elevation: 4,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: ListTile(
                                                leading: Icon(
                                                  LucideIcons.building2,
                                                  color: CustomColors.primary,
                                                ),
                                                title: Text(
                                                  orthopedicBank?.name ??
                                                      'Banco não disponível',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  orthopedicBank?.city ??
                                                      'Cidade não disponível',
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
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
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
      ),
    );
  }
}
