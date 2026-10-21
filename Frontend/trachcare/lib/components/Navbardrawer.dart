import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/components/information.dart';
import 'package:trachcare/Screens/started/WelcomePage.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:url_launcher/url_launcher.dart';

class drawer extends StatelessWidget {
  final String Name;
  final imagepath;
  final String reg_no;
  final onTap;

  drawer({
    super.key,
    required this.Name,
    required this.reg_no,
    required this.imagepath,
    required this.onTap,
  });

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchURLmail(Uri url) async {
    if (Platform.isIOS) {
      url = Uri(
        scheme: 'mailto',
        path: url.path,
        queryParameters: {'subject': 'TrachCare Support'},
      );
    }
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon:
            const Icon(Icons.logout_rounded, color: AppColors.danger, size: 32),
        title: const Text('Log out?'),
        content: const Text(
            'You will need to sign in again to continue your care plan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                textStyle: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.white)),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (context) => const Welcome_page()),
                (route) => false,
              );
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceMuted,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page,
                  AppSpacing.page, AppSpacing.page, AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceAlt,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.card,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image(
                        image: imagepath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_rounded,
                            color: AppColors.inkMuted)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 2),
                        Text(
                          'ID $reg_no',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset('assets/images/Trachcarelogo.jpg',
                    height: 62, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerTile(
                    icon: Icons.person_outline_rounded,
                    label: 'My profile',
                    onTap: onTap,
                  ),
                  _DrawerTile(
                    icon: Icons.info_outline_rounded,
                    label: 'About us',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Information()),
                    ),
                  ),
                  _DrawerTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Privacy policy',
                    onTap: () => _launchInBrowser(Uri.parse(
                        'http://180.235.121.245/Trachcare/privacy_police.html')),
                  ),
                  _DrawerTile(
                    icon: Icons.mail_outline_rounded,
                    label: 'Contact support',
                    onTap: () => _launchURLmail(Uri(
                        scheme: 'mailto', path: 'sivanesansoffical@gmail.com')),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout_rounded, size: 19),
                  label: const Text('Log out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger, width: 1.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 19, color: AppColors.teal),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                    child: Text(label,
                        style: Theme.of(context).textTheme.titleSmall)),
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.inkMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
