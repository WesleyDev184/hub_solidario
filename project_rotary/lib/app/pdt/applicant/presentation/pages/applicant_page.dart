import 'package:flutter/material.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';

class ApplicantPage extends StatelessWidget {
  final String applicantId;
  final String applicantTitle;

  const ApplicantPage({
    super.key,
    required this.applicantId,
    required this.applicantTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: applicantTitle),
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          'Detalhes do Solicitante: $applicantTitle (ID: $applicantId)',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
