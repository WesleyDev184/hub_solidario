import 'package:flutter/material.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

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
        appBar: AppBarCustom(title: 'Sobre o App', saveAction: () {}),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CustomColors.background,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: CustomColors.border.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      "https://avatars.githubusercontent.com/u/57929638?v=4",
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Wesley Antonio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {}, // Adicione a URL do LinkedIn
                    child: const Text(
                      'CTO/CEO da Roncador Labs',
                      style: TextStyle(
                        color: CustomColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'roncadorlabs@gmail.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: CustomColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Agradeço a oportunidade de contribuir com o projeto do Banco de Órteses do Rotary. Foi uma experiência enriquecedora e gratificante.',
                    style: TextStyle(
                      fontSize: 16,
                      color: CustomColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
