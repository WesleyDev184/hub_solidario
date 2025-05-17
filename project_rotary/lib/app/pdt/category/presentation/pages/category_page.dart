import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/button.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class CategoryPage extends StatelessWidget {
  final String categoryId;
  final String categoryTitle;

  const CategoryPage({
    Key? key,
    required this.categoryId,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: categoryTitle),
      backgroundColor: Colors.transparent,
      body: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Login",
                style: TextStyle(
                  color: CustomColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 10),
              Button(
                onPressed: () {},
                text: "Entrar",
                icon: Icon(LucideIcons.logIn, color: CustomColors.white),
                backgroundColor: CustomColors.success,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
