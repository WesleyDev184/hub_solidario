import 'package:app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
