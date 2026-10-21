import 'package:flutter/material.dart';
import 'package:trachcare/Screens/Views/Admin/Adminscreens/Addvideos.dart';
import 'package:trachcare/Screens/Views/Admin/Adminscreens/Doctorlist.dart';
import 'package:trachcare/Screens/Views/Admin/Adminscreens/patientslist.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

/// Admin console — the body of the Overview tab. The shell above supplies the
/// app bar, drawer and export action; this widget only routes to the areas an
/// administrator manages.
class Admindb extends StatelessWidget {
  const Admindb({super.key, this.onExport});

  final Future<void> Function()? onExport;

  void _open(BuildContext context, Widget screen, String title) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => screen,
      settings: RouteSettings(name: title),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, AppSpacing.lg, AppSpacing.page, 108),
      children: [
        const TcSectionHeader(
          eyebrow: 'Console',
          title: 'What needs managing?',
          subtitle: 'Doctors, patients and the therapy library',
        ),
        const SizedBox(height: AppSpacing.lg),
        _Destination(
          icon: Icons.groups_rounded,
          accent: AppColors.teal,
          soft: AppColors.mintSoft,
          title: 'Doctors',
          subtitle: 'Every clinician with access to this clinic',
          trailingLabel: 'Open',
          onTap: () => _open(context, const Doctorlist(), 'Doctors'),
        ),
        const SizedBox(height: AppSpacing.md),
        _Destination(
          icon: Icons.medical_information_rounded,
          accent: AppColors.sky,
          soft: AppColors.skySoft,
          title: 'Patients',
          subtitle: 'Records submitted from home, newest first',
          trailingLabel: 'Open',
          onTap: () => _open(context, const patients_list(), 'Patients'),
        ),
        const SizedBox(height: AppSpacing.md),
        _Destination(
          icon: Icons.video_library_rounded,
          accent: AppColors.violet,
          soft: AppColors.surfaceAlt,
          title: 'Therapy videos',
          subtitle: 'Upload a lesson and publish it to the WatchZone',
          trailingLabel: 'Add',
          onTap: () => _open(context, const VideoUploadPage(), 'Add videos'),
        ),
        const SizedBox(height: AppSpacing.xl),
        TcCard(
          onTap: onExport,
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: AppColors.amberSoft,
          shadows: const [],
          border: Border.all(color: const Color(0xFFF0D9AC)),
          child: Row(
            children: [
              Container(
                width: AppSize.s(40),
                height: AppSize.s(40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.thumb,
                ),
                child: Icon(Icons.table_view_rounded,
                    color: AppColors.amber, size: AppSize.s(20)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Export everything',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'A single CSV of all patient records for audit or research.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.inkBody),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.amber),
            ],
          ),
        ),
      ],
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({
    required this.icon,
    required this.accent,
    required this.soft,
    required this.title,
    required this.subtitle,
    required this.trailingLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final Color soft;
  final String title;
  final String subtitle;
  final String trailingLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TcCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: AppSize.s(48),
            height: AppSize.s(48),
            decoration:
                BoxDecoration(color: soft, borderRadius: AppRadius.thumb),
            child: Icon(icon, color: accent, size: AppSize.s(22)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TcBadge(label: trailingLabel, color: accent, background: soft),
        ],
      ),
    );
  }
}
