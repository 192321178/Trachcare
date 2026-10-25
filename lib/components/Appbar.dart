// ignore_for_file: unused_import, must_be_immutable
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trachcare/components/Notificationsheet.dart';
import 'package:trachcare/components/doctornotification.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

class Appbar extends StatelessWidget implements PreferredSizeWidget {
  final String Name;
  final double height;
  final PreferredSizeWidget? bottom;
  final bool notification;
  final List? notificationlists;
  bool? doctor = false;
  bool? export = false;
  final VoidCallback? onExportPressed;
  final String? imagePath;

  Appbar(
      {super.key,
      required this.Name,
      this.bottom,
      required this.height,
      required this.notification,
      this.notificationlists,
      this.doctor = false,
      this.export = false,
      this.onExportPressed,
      this.imagePath});

  void popsheet(BuildContext context, String Time) {
    showCupertinoModalBottomSheet(
        isDismissible: true,
        enableDrag: true,
        expand: false,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => SizedBox(
              width: double.infinity,
              child: Notificationsheetwidget(
                time: Time,
              ),
            ));
  }

  void doctorpopsheet(BuildContext context, List issuesList) {
    showCupertinoModalBottomSheet(
        isDismissible: true,
        enableDrag: true,
        expand: false,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => SizedBox(
              width: double.infinity,
              child: doctornotificationssheet(
                issuesList: issuesList,
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
        boxShadow: AppShadows.raised,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: AppBar(
            toolbarHeight: height < 70 ? 70 : height,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Builder(builder: (BuildContext context) {
            return TcIconButton(
              icon: Icons.menu_rounded,
              color: Colors.white,
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          }),
        ),
        leadingWidth: 56,
        centerTitle: false,
        titleSpacing: AppSpacing.md,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hi, $Name',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              export == true ? 'Ready to export' : 'How are you today?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.page),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                TcIconButton(
                  icon: export == true
                      ? Icons.cloud_download_rounded
                      : Icons.notifications_none_rounded,
                  color: Colors.white,
                  onPressed: () {
                    if (export == true && onExportPressed != null) {
                      onExportPressed!();
                    } else if (notification) {
                      if (doctor == false) {
                        popsheet(context, notificationlists![0].toString());
                      } else {
                        doctorpopsheet(context, notificationlists!);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('No notifications right now')),
                      );
                    }
                  },
                ),
                if (notification)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 17),
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '${notificationlists!.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: bottom,
        automaticallyImplyLeading: false,
      ),
    ),
  ),
);
  }

  @override
  Size get preferredSize => Size.fromHeight((height < 70 ? 76 : height + 6) + 12);
}
