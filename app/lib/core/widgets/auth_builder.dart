import 'package:flutter/material.dart';

class AuthBuilder extends StatefulWidget {
  final Widget child;

  const AuthBuilder({super.key, required this.child});

  @override
  State<AuthBuilder> createState() => _AuthBuilderState();
}

class _AuthBuilderState extends State<AuthBuilder> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
