import 'package:flutter/material.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

class Notificationsheetwidget extends StatelessWidget {
  final String time;

  const Notificationsheetwidget({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.amberSoft,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.notifications_active_rounded,
                        color: AppColors.amber, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notification centre',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('1 reminder for you',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.inkMuted)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _ReminderCard(time: time),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.horizontal,
      onDismissed: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder dismissed')),
        );
      },
      child: TcCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        border: const Border(
          left: BorderSide(color: AppColors.amber, width: 4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spigotting status', style: AppType.eyebrow),
                  const SizedBox(height: 5),
                  Text(
                    'You missed the $time routine',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Log it now so your doctor sees an up to date record.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
          ],
        ),
      ),
    );
  }
}
