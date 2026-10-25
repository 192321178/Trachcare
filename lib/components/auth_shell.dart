import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

/// The brand header + white sheet used by every screen in the auth flow.
///
/// Mirrors the header/sheet split in figma-import/png/03..05 so sign-in,
/// sign-up and password reset stay visually identical.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.portal,
    required this.headline,
    required this.hint,
    required this.roleIcon,
    required this.sheetTitle,
    required this.child,
  });

  final String portal;
  final String headline;
  final String hint;
  final IconData roleIcon;
  final String sheetTitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            // Without stretch the header's Stack shrink-wraps to its widest
            // child and the centered Column floats it right, which pushes the
            // back chevron on top of the eyebrow text.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                  portal: portal, headline: headline, hint: hint, roleIcon: roleIcon),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.sheet,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.md,
                      AppSpacing.page,
                      AppSpacing.xxxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SheetHandle(),
                        SizedBox(height: AppSize.s(22)),
                        Text(
                          sheetTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: AppSize.s(19),
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: AppSize.s(26)),
                        child,
                      ],
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

class _Header extends StatelessWidget {
  const _Header({
    required this.portal,
    required this.headline,
    required this.hint,
    required this.roleIcon,
  });

  final String portal;
  final String headline;
  final String hint;
  final IconData roleIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.page, AppSpacing.lg, AppSpacing.page, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TcIconButton(
                icon: Icons.chevron_left_rounded,
                onPressed: () => Navigator.maybePop(context),
                color: Colors.white,
              ),
              Container(
                width: AppSize.s(52),
                height: AppSize.s(52),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(roleIcon, size: AppSize.s(26), color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: AppSize.s(16)),
          Text(
            portal.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSize.s(10),
              fontWeight: FontWeight.w700,
              letterSpacing: AppSize.s(1.6),
              color: AppColors.mint,
            ),
          ),
          SizedBox(height: AppSize.s(4)),
          Text(
            headline,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSize.s(28),
              fontWeight: FontWeight.w800,
              letterSpacing: AppSize.s(-0.8),
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSize.s(8)),
          Text(
            hint,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSize.s(13),
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

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

/// A field with the label sitting above the box, as drawn in the mock.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.textInputAction = TextInputAction.next,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.onFieldSubmitted,
    this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onFieldSubmitted;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSize.s(2), bottom: AppSize.s(6)),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSize.s(12),
              fontWeight: FontWeight.w600,
              color: AppColors.inkBody,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          cursorColor: AppColors.teal,
          autofillHints: obscure
              ? const [AutofillHints.password]
              : const [AutofillHints.email],
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSize.s(15),
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon:
                Icon(icon, size: AppSize.s(19), color: AppColors.inkMuted),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// A checkbox row matching the "Keep me signed in" control in the mock.
class AuthCheck extends StatelessWidget {
  const AuthCheck({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: AppSize.s(20),
            height: AppSize.s(20),
            decoration: BoxDecoration(
              color: value ? AppColors.mint : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSize.s(6)),
              border: Border.all(
                color: value ? AppColors.mint : AppColors.outline,
                width: 1.4,
              ),
            ),
            child: value
                ? Icon(Icons.check_rounded,
                    size: AppSize.s(14), color: AppColors.tealDeep)
                : null,
          ),
          SizedBox(width: AppSize.s(8)),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSize.s(12.5),
              fontWeight: FontWeight.w600,
              color: AppColors.inkBody,
            ),
          ),
        ],
      ),
    );
  }
}

class HairlineLabel extends StatelessWidget {
  const HairlineLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.s(12)),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSize.s(9),
              fontWeight: FontWeight.w700,
              letterSpacing: AppSize.s(1.4),
              color: AppColors.inkMuted,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}

class PrivacyNote extends StatelessWidget {
  const PrivacyNote({super.key, this.text = _default});

  static const _default =
      'Your details are only used to open your TrachCare account.';
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.s(14)),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: AppRadius.field,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 16, color: AppColors.teal),
          SizedBox(width: AppSize.s(10)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSize.s(11.5),
                height: 1.4,
                color: AppColors.inkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
