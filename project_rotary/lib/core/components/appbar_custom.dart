import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

const _primaryBg = CustomColors.white;
const _primaryColor = CustomColors.textPrimary;

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustom({
    super.key,
    required this.closeAction,
    required this.saveAction,
    required this.title,
  });

  final void Function() closeAction;
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
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: closeAction,
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
                  icon: Icon(Icons.menu),
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
                                      Icons.home,
                                      color: CustomColors.primary,
                                    ),
                                    title: Text('Home'),
                                  ),

                                  Divider(),
                                  ListTile(
                                    leading: Icon(
                                      Icons.perm_identity,
                                      color: CustomColors.primary,
                                    ),
                                    title: Text('Settings'),
                                  ),

                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(
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
