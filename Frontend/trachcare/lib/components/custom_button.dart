import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/utils/Dimention.dart';

class custom_Button extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final Color backgroundColor;
  final double textSize;
  final button_funcation;
  final IconData? icon;
  final Color textcolor;
  final List<BoxShadow>? boxShadow;

  const custom_Button({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    required this.backgroundColor,
    this.boxShadow,
    this.button_funcation,
    this.icon,
    required this.textcolor,
    required this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = button_funcation != null;
    final dn = Dimentions(context);
    final labelColor = enabled
        ? (textcolor == Colors.white ? Colors.white : textcolor)
        : AppColors.inkMuted;

    return SizedBox(
      width: dn.width(width),
      height: dn.height(height),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: [
                    backgroundColor,
                    Color.lerp(backgroundColor, Colors.white, 0.22)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : AppColors.surfaceAlt,
          borderRadius: AppRadius.button,
          boxShadow: boxShadow ?? (enabled ? AppShadows.raised : null),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: button_funcation,
            borderRadius: AppRadius.button,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: labelColor),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: textSize,
                        color: labelColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
