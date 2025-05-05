import 'package:flutter/material.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

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
        appBar: AppBarCustom(
          title: 'Categories',
          closeAction: () {
            Navigator.pushReplacementNamed(context, '/');
          },
          saveAction: () {},
        ),
        body: Stack(
          children: [
            const Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Text('Categories'),
            ),
          ],
        ),
      ),
    );
  }
}
