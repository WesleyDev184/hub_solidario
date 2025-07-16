import 'package:app/app/auth/widgets/signin_form.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';

import 'widgets/header_logo.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.primary,
        image: DecorationImage(
          image: const AssetImage("assets/images/bg.jpg"),
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
              width: double.infinity,
              padding: const EdgeInsets.only(top: 70),
              child: const HeaderLogo(),
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
  }
}
