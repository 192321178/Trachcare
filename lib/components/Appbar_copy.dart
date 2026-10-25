import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/style/design_system.dart';

class Duplicate_Appbar extends StatelessWidget implements PreferredSizeWidget {
  final String Title;
  final double height;

  const Duplicate_Appbar(
      {super.key, required this.Title, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: AppShadows.raised,
      ),
      child: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.page,
        title: Text(
          Title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(68);
}
