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
        body: Stack(
          children: [
            const Positioned(top: 100, left: 0, right: 0, child: HeaderLogo()),
            Positioned(bottom: 0, left: 0, right: 0, child: SingInForm()),
          ],
        ),
      ),
    );
  }
}
