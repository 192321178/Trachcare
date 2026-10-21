import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/Login.dart';
import 'package:trachcare/components/auth_screen.dart';
import 'package:trachcare/style/design_system.dart';

class DoctorLogin extends StatelessWidget {
  const DoctorLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreen(
      role: 'Doctor',
      portal: 'Doctor portal',
      hint: 'Review your patients, daily vitals and spigotting progress.',
      roleIcon: Icons.insights_rounded,
      idIcon: Icons.medical_information_outlined,
      actionGradient: const LinearGradient(
        colors: [AppColors.teal, AppColors.sky],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      onSubmit: () => LoginClassApi().DoctorLogin(context),
    );
  }
}
