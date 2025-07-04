import 'package:flutter/material.dart';
import 'package:project_rotary/app/auth/presentation/widgets/signin_form.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

import '../widgets/header_logo.dart';

class SingInPage extends StatelessWidget {
  const SingInPage({super.key});

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
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/test-image'),
          backgroundColor: Colors.orange,
          child: const Icon(Icons.camera_alt, color: Colors.white),
          tooltip: 'Testar Image Uploader',
        ),
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
                child: SingInForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
