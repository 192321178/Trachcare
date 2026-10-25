import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/services/reminder_service.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

/// Lets the patient see, and switch off, every message the phone will send.
///
/// The schedule is derived, not typed: medication slots come from the
/// prescription the doctor filed, and the airway checks open at the same hours
/// the dashboard's spigotting grid uses. This screen only decides whether each
/// derived slot is allowed to fire.
class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final _service = ReminderService.instance;
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _service.init();
      if (!mounted) return;
      _name.text = _service.patientName;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    FocusScope.of(context).unfocus();
    await _service.setPatientName(_name.text);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _service.buildSchedule();
    final medication =
        schedule.where((r) => r.group == ReminderGroup.medication).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Care reminders'),
        leading: const BackButton(),
        backgroundColor: AppColors.surfaceMuted,
        foregroundColor: AppColors.ink,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.xxxl),
        children: [
          TcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personalised with', style: AppType.eyebrow),
                SizedBox(height: AppSize.s(6)),
                TextField(
                  controller: _name,
                  onSubmitted: (_) => _saveName(),
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Your name',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                    suffixIcon: Icon(Icons.check_rounded,
                        size: 20, color: AppColors.teal),
                  ),
                ),
                SizedBox(height: AppSize.s(8)),
                Text(
                  'Every message opens with this name, so it reads as yours rather than a broadcast.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSize.s(22)),
          TcSectionHeader(
            eyebrow: 'Delivery',
            title: 'What TrachCare sends',
            subtitle: 'Switch off anything that no longer applies to you',
          ),
          SizedBox(height: AppSize.s(12)),
          for (final group in ReminderGroup.values)
            Padding(
              padding: EdgeInsets.only(bottom: AppSize.s(10)),
              child: _GroupTile(
                group: group,
                enabled: _service.toggles.isEnabled(group),
                count: schedule.where((r) => r.group == group).length,
                onChanged: (v) async {
                  await _service.setGroupEnabled(group, v);
                  if (!mounted) return;
                  setState(() {});
                },
              ),
            ),
          if (_service.toggles.isEnabled(ReminderGroup.medication)) ...[
            SizedBox(height: AppSize.s(16)),
            TcSectionHeader(
              eyebrow: 'Prescription',
              title: 'Tablet slots',
              subtitle: 'Before food lands 30 min early, after food 45 min late',
            ),
            SizedBox(height: AppSize.s(12)),
            TcCard(
              child: Column(
                children: [
                  for (final slot in medication)
                    _SlotRow(
                      reminder: slot,
                      enabled: _slotEnabled(slot),
                      onChanged: (v) async {
                        await _setSlot(slot, v);
                        if (!mounted) return;
                        setState(() {});
                      },
                    ),
                  if (medication.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(AppSize.s(8)),
                      child: Text(
                        'No tablet slots are on. Your doctor sets these when they file your medication.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.inkMuted),
                      ),
                    ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSize.s(22)),
          TcSectionHeader(
            eyebrow: 'Today',
            title: 'Message queue',
            subtitle:
                '${schedule.length} message${schedule.length == 1 ? '' : 's'} armed on this phone',
          ),
          SizedBox(height: AppSize.s(12)),
          TcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final slot in schedule)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSize.s(12)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: AppSize.s(48),
                          child: Text(
                            slot.clock,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: AppSize.s(13),
                              fontWeight: FontWeight.w800,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(slot.title,
                                  style: Theme.of(context).textTheme.titleSmall),
                              SizedBox(height: AppSize.s(2)),
                              Text(
                                slot.body,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.inkMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (schedule.isEmpty)
                  Text(
                    'Nothing is armed. Turn a group back on above.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.inkMuted),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSize.s(16)),
          Text(
            'Reminders are handed to Android, so they still fire with TrachCare closed. Battery optimisation can delay them — allow the app to run in the background if a message is late.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.inkMuted, height: 1.5),
          ),
        ],
      ),
    );
  }

  bool _slotEnabled(CareReminder slot) {
    final t = _service.toggles;
    return switch (slot.id) {
      101 => t.morningBefore,
      102 => t.morningAfter,
      103 => t.afternoonBefore,
      104 => t.afternoonAfter,
      105 => t.nightBefore,
      106 => t.nightAfter,
      _ => true,
    };
  }

  Future<void> _setSlot(CareReminder slot, bool enabled) {
    final (group, before) = switch (slot.id) {
      101 || 102 => ('morning', slot.id == 101),
      103 || 104 => ('afternoon', slot.id == 103),
      _ => ('night', slot.id == 105),
    };
    return _service.setMedicationSlot(group, before, enabled);
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.enabled,
    required this.count,
    required this.onChanged,
  });

  final ReminderGroup group;
  final bool enabled;
  final int count;
  final ValueChanged<bool> onChanged;

  static const _icons = {
    ReminderGroup.medication: Icons.medication_outlined,
    ReminderGroup.meals: Icons.restaurant_menu_rounded,
    ReminderGroup.airway: Icons.air_rounded,
    ReminderGroup.report: Icons.assignment_outlined,
    ReminderGroup.therapy: Icons.play_circle_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return TcCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: AppSize.s(38),
            height: AppSize.s(38),
            decoration: BoxDecoration(
              color: enabled ? AppColors.mintSoft : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppSize.s(12)),
            ),
            child: Icon(
              _icons[group],
              size: AppSize.s(19),
              color: enabled ? AppColors.teal : AppColors.inkMuted,
            ),
          ),
          SizedBox(width: AppSize.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.label, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  '$count a day · ${group.blurb}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeThumbColor: AppColors.teal,
          ),
        ],
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.reminder,
    required this.enabled,
    required this.onChanged,
  });

  final CareReminder reminder;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: AppSize.s(48),
          child: Text(
            reminder.clock,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSize.s(12.5),
              fontWeight: FontWeight.w700,
              color: enabled ? AppColors.teal : AppColors.inkMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            reminder.group == ReminderGroup.medication
                ? reminder.body
                : reminder.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Switch(value: enabled, onChanged: onChanged, activeThumbColor: AppColors.teal),
      ],
    );
  }
}
