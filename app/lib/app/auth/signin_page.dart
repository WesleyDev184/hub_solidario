import 'package:app/app/auth/widgets/signin_form.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int displayWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth.round()
            : 412;
        final int displayHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight.round()
            : 857;
        return Container(
          decoration: BoxDecoration(
            color: CustomColors.primary,
            image: DecorationImage(
              image: ResizeImage(
                const AssetImage("assets/images/bg.jpg"),
                width: displayWidth,
                height: displayHeight,
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                CustomColors.primarySwatch.shade100,
                BlendMode.dstATop,
              ),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                // Header fixo com logo
                Container(
                  height: 220,
                  width: 300,
                  padding: const EdgeInsets.only(top: 70),
                  child: Image.asset('assets/images/hubs.png', width: 200),
                ),
                // Formulário fixo no fundo
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: SigninForm(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
