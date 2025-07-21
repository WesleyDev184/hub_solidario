import 'package:app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: CustomColors.white,
            image: DecorationImage(
              image: const AssetImage("assets/images/bg.jpg"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                CustomColors.primarySwatch.shade100.withOpacity(0.3),
                BlendMode.dstATop,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
