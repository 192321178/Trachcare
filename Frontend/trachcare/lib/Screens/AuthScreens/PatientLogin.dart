import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/Login.dart';
import 'package:trachcare/components/auth_screen.dart';
import 'package:trachcare/style/design_system.dart';

class patientScreenlogin extends StatelessWidget {
  const patientScreenlogin({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreen(
      role: 'Patient',
      portal: 'Patient portal',
      hint: 'Log in to view your therapy plan and daily breathing sessions.',
      roleIcon: Icons.favorite_outline_rounded,
      actionGradient: AppColors.brandGradient,
      onSubmit: () => LoginClassApi().Patientlogin(context),
    );
  }
}
