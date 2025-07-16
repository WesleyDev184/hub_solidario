import 'package:app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';

import 'widgets/header_logo.dart';
import 'widgets/signup_form.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 200,
              collapsedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.only(top: 70),
                  child: const HeaderLogo(),
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
              child: Column(
                children: [
                  Expanded(
                    child:
                        Container(), // Espaço flexível para empurrar o form para baixo
                  ),
                  SignUpForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
