import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

class NormalAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String Title;
  final double height;
  final Widget? actionbutton;
  final VoidCallback? onTap;
  final String? subtitle;
  final bool export;
  final bool menu;
  final VoidCallback? onExportPressed;

  NormalAppbar({
    super.key,
    required this.Title,
    this.onTap,
    this.actionbutton,
    required this.height,
    this.export = false,
    this.menu = false,
    this.subtitle,
    this.onExportPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget? leading;
    if (menu) {
      leading = IconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
      );
    } else if (onTap != null) {
      leading = IconButton(
        onPressed: onTap,
        icon:
            const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
        boxShadow: AppShadows.raised,
      ),
      child: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: leading,
        centerTitle: false,
        titleSpacing: leading == null ? AppSpacing.page : 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 17,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
          ],
        ),
        actions: [
          if (export)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.page),
              child: TcIconButton(
                icon: Icons.cloud_download_rounded,
                color: Colors.white,
                onPressed: onExportPressed,
              ),
            ),
          if (actionbutton != null) actionbutton!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
