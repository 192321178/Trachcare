import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/Login.dart';
import 'package:trachcare/components/auth_screen.dart';
import 'package:trachcare/style/design_system.dart';

class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreen(
      role: 'Admin',
      portal: 'Admin portal',
      hint: 'Manage doctors, patients and the therapy video library.',
      roleIcon: Icons.grid_view_rounded,
      idLabel: 'Username or Email',
      idIcon: Icons.workspace_premium_outlined,
      validateId: requiredText,
      actionGradient: const LinearGradient(
        colors: [AppColors.teal, AppColors.violet],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      onSubmit: () => LoginClassApi().Adminlogin(context),
    );
  }
}
