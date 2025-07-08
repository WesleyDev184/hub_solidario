import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  // Dados mocados do usuário
  final String _userName = "João Silva";
  final String _userEmail = "joao.silva@rotary.org";
  final String _userPhone = "(11) 99999-9999";
  final String _bankName = "Banco Ortopédico Central";
  final String _bankCity = "São Paulo - SP";

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

    if (shouldLogout == true && mounted) {
      // Simula logout e navega para a tela de login
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil('/', (route) => false);
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

                                  // Seção de dados do usuário com dados mocados
                                  Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(
                                          LucideIcons.idCard,
                                          color: CustomColors.textPrimary,
                                        ),
                                        title: Text(_userName),
                                      ),

                                      Divider(),
                                      ListTile(
                                        leading: Icon(
                                          LucideIcons.mail,
                                          color: CustomColors.textPrimary,
                                        ),
                                        title: Text(_userEmail),
                                      ),

                                      Divider(),
                                      ListTile(
                                        leading: Icon(
                                          LucideIcons.phone,
                                          color: CustomColors.textPrimary,
                                        ),
                                        title: Text(_userPhone),
                                      ),
                                    ],
                                  ),

                                  Spacer(),

                                  // Seção do banco ortopédico com dados mocados
                                  Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        LucideIcons.building2,
                                        color: CustomColors.primary,
                                      ),
                                      title: Text(
                                        _bankName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(_bankCity),
                                    ),
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
