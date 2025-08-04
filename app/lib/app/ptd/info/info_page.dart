import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});
  Uri get _url => Uri.parse('https://www.linkedin.com/in/wesleyantonio');

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
                color: CustomColors.primary,
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
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBarCustom(title: 'Agradecimento'),
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
                        Avatar(
                          imageUrl:
                              "https://avatars.githubusercontent.com/u/57929638?v=4",
                          size: 120,
                          isNetworkImage: true,
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
                          onPressed: _launchUrl,
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
          ],
        );
      },
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
