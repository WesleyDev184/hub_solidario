import 'package:flutter/material.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';

class LoanPage extends StatelessWidget {
  final String loanId;
  final String loanTitle;

  const LoanPage({super.key, required this.loanId, required this.loanTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: loanTitle),
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          'Detalhes do empréstimo: $loanTitle (ID: $loanId)',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
