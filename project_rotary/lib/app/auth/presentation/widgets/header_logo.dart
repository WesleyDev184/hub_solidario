import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class HeaderLogo extends StatelessWidget {
  const HeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset('assets/images/rotary.svg', width: 200),
        const Text(
          'Sistema de Gestão Rotary',
          style: TextStyle(color: CustomColors.white, fontSize: 15),
        ),
      ],
    );
  }
}
