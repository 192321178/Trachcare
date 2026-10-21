import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/json_client.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

String _shown(String value) => value.isEmpty ? 'Not recorded' : value;

/// One day of a patient's home report, read-only.
class Viewdailyupdates extends StatefulWidget {
  final String name;
  final String imagePath;
  final String selecteddate;
  final String patientId;

  const Viewdailyupdates({
    super.key,
    required this.name,
    required this.imagePath,
    required this.selecteddate,
    required this.patientId,
  });

  @override
  State<Viewdailyupdates> createState() => _ViewdailyupdatesState();
}

class _ViewdailyupdatesState extends State<Viewdailyupdates> {
  late Future<dynamic> _day = _load();

  Future<dynamic> _load() async {
    final raw = await fetchJson(
        '$ViewDailyVitalsUrl?patient_id=${widget.patientId}&date=${widget.selecteddate}');
    final rows = raw is Map ? raw['patient_details'] : null;
    if (rows is List && rows.isNotEmpty) return rows.first;
    return null;
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _day = next);
    await next;
  }

  Widget _yn(BuildContext context, String label, bool? yes,
      {bool alarm = false}) {
    if (yes == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            const Icon(Icons.help_outline_rounded,
                size: 18, color: AppColors.inkMuted),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child:
                    Text(label, style: Theme.of(context).textTheme.bodyMedium)),
            Text('Not answered',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.inkMuted)),
          ],
        ),
      );
    }

    final flagged = alarm && yes;
    final color = flagged
        ? AppColors.danger
        : (yes ? AppColors.success : AppColors.inkMuted);
    final soft = flagged
        ? AppColors.dangerSoft
        : (yes ? AppColors.successSoft : AppColors.surfaceAlt);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            yes
                ? Icons.check_circle_rounded
                : Icons.remove_circle_outline_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
              child:
                  Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          TcBadge(label: yes ? 'Yes' : 'No', color: color, background: soft),
        ],
      ),
    );
  }

  Widget _note(BuildContext context, String label, String value,
      {IconData icon = Icons.edit_note_rounded}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.inkMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
              child:
                  Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppbar(
        Title: 'Daily report',
        subtitle: 'Entry for ${widget.selecteddate}',
        height: 92,
        onTap: () => Navigator.maybePop(context),
      ),
      body: FutureBuilder(
        future: _day,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.page),
              child: Column(
                children: [
                  TcSkeleton(height: 96, radius: 20),
                  SizedBox(height: AppSpacing.xl),
                  TcSkeleton(height: 108, radius: 20),
                  SizedBox(height: AppSpacing.md),
                  TcSkeleton(height: 220, radius: 20),
                ],
              ),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return TcEmptyState(
              icon: Icons.event_busy_rounded,
              title: 'Nothing filed for this day',
              message: snapshot.hasError
                  ? 'We could not reach the record. Try again.'
                  : 'The patient did not submit a report on ${widget.selecteddate}.',
              action: TcButton(
                label: 'Try again',
                icon: Icons.refresh_rounded,
                expand: false,
                onPressed: _refresh,
              ),
            );
          }

          final data = snapshot.data as Map;
          String text(String key) {
            final value = data[key];
            return value == null ? '' : value.toString().trim();
          }

          bool? yes(String key) {
            final value = text(key);
            if (value.isEmpty) return null;
            return value.toLowerCase() == 'yes';
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, AppSpacing.lg, AppSpacing.page, 40),
              children: [
                TcPatientHeader(
                  name: widget.name,
                  patientId: 'Patient ID ${widget.patientId}',
                  imagePath: trachcareAsset(widget.imagePath),
                ),
                const SizedBox(height: AppSpacing.xl),
                TcSectionHeader(eyebrow: 'Vitals', title: 'Recorded at home'),
                Row(
                  children: [
                    Expanded(
                      child: TcStatTile(
                        icon: Icons.air_rounded,
                        label: 'Respiratory rate',
                        value: _shown(text('respiratory_rate')),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TcStatTile(
                        icon: Icons.favorite_rounded,
                        label: 'Heart rate',
                        value: _shown(text('heart_rate')),
                        accent: AppColors.coral,
                        accentSoft: AppColors.coralSoft,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TcStatTile(
                        icon: Icons.water_drop_rounded,
                        label: 'SpO2',
                        value: _shown(text('spo2_room_air')),
                        accent: AppColors.sky,
                        accentSoft: AppColors.skySoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                const TcSectionHeader(title: 'Airway care'),
                TcCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _yn(context, 'Daily dressing done',
                          yes('daily_dressing_done')),
                      _yn(context, 'Tracheostomy tie changed',
                          yes('tracheostomy_tie_changed')),
                      _yn(context, 'Suctioning done', yes('suctioning_done')),
                      if (yes('suctioning_done') == true)
                        _note(context, 'Secretion colour and consistency',
                            _shown(text('secretion_color_consistency'))),
                      _yn(context, 'Changed to green tube',
                          yes('changed_to_green_tube')),
                      _note(context, 'Spigotting status',
                          _shown(text('spigotting_status')),
                          icon: Icons.timelapse_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const TcSectionHeader(title: 'Feeding and breathing trial'),
                TcCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _yn(context, 'Started oral feeds',
                          yes('oral_feeds_started')),
                      if (yes('oral_feeds_started') == true)
                        _yn(context, 'Cough or breathlessness',
                            yes('cough_or_breathlessness'),
                            alarm: true),
                      _yn(context, 'Breathes through nose with tube blocked',
                          yes('able_to_breathe_through_nose')),
                      if (yes('able_to_breathe_through_nose') == true)
                        _note(context, 'Breath duration',
                            _shown(text('breath_duration'))),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
