import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/components/button.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

const _primaryBg = CustomColors.white;
const _primaryColor = CustomColors.textPrimary;

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustom({
    super.key,
    required this.saveAction,
    required this.title,
  });

  final void Function() saveAction;
  final String title;

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
            padding: EdgeInsets.only(bottom: 8, top: 4, left: 8, right: 8),
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
                        Navigator.of(context).pushNamed('/info');
                      },
                      color: _primaryColor,
                    ),

                Text(
                  title,
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

                                  ListTile(
                                    leading: Icon(
                                      LucideIcons.idCard,
                                      color: CustomColors.textPrimary,
                                    ),
                                    title: Text('Nome'),
                                  ),

                                  Divider(),
                                  ListTile(
                                    leading: Icon(
                                      LucideIcons.mail,
                                      color: CustomColors.textPrimary,
                                    ),
                                    title: Text('Email'),
                                  ),

                                  Divider(),
                                  ListTile(
                                    leading: Icon(
                                      LucideIcons.phone,
                                      color: CustomColors.textPrimary,
                                    ),
                                    title: Text('Phone'),
                                  ),

                                  Spacer(),
                                  Button(
                                    text: "Sair",
                                    icon: Icon(
                                      LucideIcons.logOut,
                                      color: CustomColors.white,
                                    ),
                                    backgroundColor: CustomColors.error,
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        '/',
                                        (route) => false,
                                      );
                                    },
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
