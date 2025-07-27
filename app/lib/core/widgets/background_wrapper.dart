import 'package:app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundWrapper({super.key, required this.child});

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
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: CustomColors.white,
                image: DecorationImage(
                  image: ResizeImage(
                    const AssetImage("assets/images/bg.jpg"),
                    width: displayWidth,
                    height: displayHeight,
                  ),
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
      },
    );
  }
}
