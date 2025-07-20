import 'package:app/core/api/auth/controllers/auth_controller.dart';
import 'package:app/core/api/auth/models/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routefly/routefly.dart';

class AuthBuilder extends StatefulWidget {
  final Widget child;

  const AuthBuilder({super.key, required this.child});

  @override
  State<AuthBuilder> createState() => _AuthBuilderState();
}

class _AuthBuilderState extends State<AuthBuilder> {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    ever<AuthState>(_authController.stateRx, (state) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('Builder ever: checkUserPermissions called with state');
        _authController.checkUserPermissions(Routefly.currentUri.path, false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
