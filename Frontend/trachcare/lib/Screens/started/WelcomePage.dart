import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/Screens/AuthScreens/Adminlogin.dart';
import 'package:trachcare/Screens/AuthScreens/Doctorlogin.dart';
import 'package:trachcare/Screens/AuthScreens/PatientLogin.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

/// Role picker.
///
/// Mirrors figma-import/png/02-welcome-role-picker: brand header, then a white
/// sheet holding the two self-serve roles as icon rows and admin as a text
/// link, since staff never pick their way in the same way a patient does.
class Welcome_page extends StatelessWidget {
  const Welcome_page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _WelcomeHeader(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.sheet,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.md,
                        AppSpacing.page, AppSpacing.xxxl),
                    child: ContentColumn(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SheetHandle(),
                          SizedBox(height: AppSize.s(22)),
                          Text(
                            'CHOOSE HOW YOU WANT TO CONTINUE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: AppSize.s(10),
                              fontWeight: FontWeight.w700,
                              letterSpacing: AppSize.s(1.4),
                              color: AppColors.inkMuted,
                            ),
                          ),
                          SizedBox(height: AppSize.s(16)),
                          _RoleRow(
                            title: 'Patient',
                            description: 'Daily routine, videos and records',
                            icon: Icons.person_outline_rounded,
                            accent: AppColors.teal,
                            accentSoft: AppColors.mintSoft,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const patientScreenlogin()),
                            ),
                          ),
                          SizedBox(height: AppSize.s(12)),
                          _RoleRow(
                            title: 'Doctor',
                            description: 'Review patients and update plans',
                            icon: Icons.medical_information_outlined,
                            accent: AppColors.sky,
                            accentSoft: AppColors.skySoft,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DoctorLogin()),
                            ),
                          ),
                          SizedBox(height: AppSize.s(20)),
                          const _OrDivider(),
                          SizedBox(height: AppSize.s(14)),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AdminLogin()),
                              ),
                              icon: Icon(Icons.verified_user_outlined,
                                  size: AppSize.s(17)),
                              label: const Text('Continue as clinic admin'),
                            ),
                          ),
                          SizedBox(height: AppSize.s(16)),
                          Text(
                            "Protected health information stays on this device's account only.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: AppSize.s(11),
                              height: 1.45,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.page, AppSpacing.lg, AppSpacing.page, AppSpacing.xl),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WELCOME TO',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppSize.s(10),
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppSize.s(1.6),
                  color: AppColors.mint,
                ),
              ),
              SizedBox(height: AppSize.s(4)),
              Text(
                'TrachCare',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppSize.s(30),
                  fontWeight: FontWeight.w800,
                  letterSpacing: AppSize.s(-0.8),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppSize.s(8)),
              SizedBox(
                width: AppSize.s(250),
                child: Text(
                  'Your guided airway routine at home – every day, every check, in one place.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: AppSize.s(13),
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: AppSize.s(2),
            right: AppSize.s(4),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: AppSize.s(22),
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: AppSize.s(38),
          height: AppSize.s(4),
          decoration: BoxDecoration(
            color: AppColors.outline,
            borderRadius: AppRadius.chip,
          ),
        ),
      );
}

class _RoleRow extends StatelessWidget {
  const _RoleRow({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.accentSoft,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final Color accentSoft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration:
          BoxDecoration(borderRadius: AppRadius.card, boxShadow: AppShadows.card),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.card,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSize.s(14), vertical: AppSize.s(14)),
            child: Row(
              children: [
                Container(
                  width: AppSize.s(44),
                  height: AppSize.s(44),
                  decoration: BoxDecoration(
                    color: accentSoft,
                    borderRadius: BorderRadius.circular(AppSize.s(13)),
                  ),
                  child: Icon(icon, size: AppSize.s(21), color: accent),
                ),
                SizedBox(width: AppSize.s(13)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppSize.s(16),
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: AppSize.s(3)),
                      Text(
                        description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppSize.s(11.5),
                          height: 1.35,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: AppSize.s(22), color: AppColors.inkMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.s(12)),
          child: Text(
            'or',
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSize.s(11),
              fontWeight: FontWeight.w600,
              color: AppColors.inkMuted,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}
