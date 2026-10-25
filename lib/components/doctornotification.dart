import 'package:flutter/material.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

/// The doctor's bell sheet — patients whose latest report flagged breathing
/// trouble, presented over the dashboard as a bottom sheet.
class doctornotificationssheet extends StatelessWidget {
  const doctornotificationssheet({super.key, required this.issuesList});

  final List issuesList;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.sheet,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppSize.s(10)),
            Center(
              child: Container(
                width: AppSize.s(42),
                height: AppSize.s(4),
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(AppSize.s(2)),
                ),
              ),
            ),
            SizedBox(height: AppSize.s(14)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Row(
                children: [
                  Container(
                    width: AppSize.s(44),
                    height: AppSize.s(44),
                    decoration: BoxDecoration(
                      color: AppColors.amberSoft,
                      borderRadius: BorderRadius.circular(AppSize.s(14)),
                    ),
                    child: Icon(Icons.notifications_active_outlined,
                        color: AppColors.amber, size: AppSize.s(22)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notification centre', style: AppType.eyebrow),
                        SizedBox(height: AppSize.s(3)),
                        Text('Needs attention',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                  TcIconButton(
                    icon: Icons.close_rounded,
                    size: 36,
                    background: AppColors.surfaceMuted,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSize.s(6)),
            if (issuesList.isEmpty)
              Padding(
                padding: EdgeInsets.all(AppSize.s(28)),
                child: const TcEmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'All clear',
                  message: 'No patient has flagged a breathing issue today.',
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.page,
                      AppSpacing.sm, AppSpacing.page, AppSpacing.xl),
                  itemCount: issuesList.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: AppSize.s(10)),
                  itemBuilder: (context, index) => _AlertTile(
                    patientName:
                        issuesList[index]['username']?.toString() ?? 'Patient',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.patientName});

  final String patientName;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification dismissed')),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: AppRadius.card,
        ),
        child:
            const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      child: TcCard(
        shadows: null,
        border: Border.all(color: AppColors.outline),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: AppSize.s(42),
              height: AppSize.s(42),
              decoration: BoxDecoration(
                color: AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(AppSize.s(13)),
              ),
              child: Icon(Icons.emergency_rounded,
                  color: AppColors.danger, size: AppSize.s(21)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patientName,
                      style: Theme.of(context).textTheme.titleSmall),
                  SizedBox(height: AppSize.s(2)),
                  Text(
                    'Reported breathing difficulty in the latest daily report',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.inkMuted, height: 1.4),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSize.s(8)),
            const TcBadge(
              label: 'Urgent',
              color: AppColors.danger,
              background: AppColors.dangerSoft,
            ),
          ],
        ),
      ),
    );
  }
}
