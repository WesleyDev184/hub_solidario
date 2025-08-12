import 'package:app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';

import 'widgets/signup_form.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: 200,
                  collapsedHeight: 130,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.only(top: 70),
                      child: Image.asset('assets/images/hubs.png', width: 200),
                    ),
                    collapseMode: CollapseMode.parallax,
                  ),
                  pinned: true,
                  floating: false,
                  automaticallyImplyLeading: false,
                  stretch: true,
                  stretchTriggerOffset: 150.0,
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(children: [SignUpForm()]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
