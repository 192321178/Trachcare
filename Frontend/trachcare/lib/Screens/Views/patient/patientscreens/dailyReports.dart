import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/Screens/Views/patient/patientscreens/calender.dart';
import 'package:trachcare/style/design_system.dart';

/// Read-only view of the daily queries report saved for one date.
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
  Map<String, dynamic> patientData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  Future<void> fetchPatientData() async {
    setState(() => isLoading = true);
    final url = Uri.parse(
        '$ViewDailyVitalsUrl?patient_id=${widget.patientId}&date=${widget.selecteddate}');
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to load patient data: ${response.statusCode}');
      }
      final data = jsonDecode(response.body);
      final details = data['patient_details'];
      if (!mounted) return;
      setState(() {
        patientData = (details != null && details.isNotEmpty)
            ? Map<String, dynamic>.from(details[0])
            : <String, dynamic>{};
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Error fetching patient data: $error');
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _value(String key) => patientData[key]?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppbar(
        Title: widget.selecteddate,
        subtitle: 'Daily queries report',
        height: 92,
        onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => calender(
            name: widget.name,
            imagePath: widget.imagePath,
          ),
        )),
      ),
      body: isLoading
          ? const _ReportSkeleton()
          : patientData['respiratory_rate'] == null
              ? TcEmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No report for this date',
                  message:
                      'No daily queries were submitted on ${widget.selecteddate}.',
                )
              : RefreshIndicator(
                  onRefresh: fetchPatientData,
                  color: AppColors.teal,
                  child: ListView(
                    padding: const EdgeInsets.only(
                        top: AppSpacing.lg, bottom: AppSpacing.xxxl),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.page),
                        child: Column(
                          children: [
                            TcPatientHeader(
                              name: widget.name,
                              patientId: widget.patientId,
                              imagePath: trachcareAsset('${widget.imagePath}'),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _VitalRow(
                              vitals: [
                                _Vital(
                                    'Respiratory rate',
                                    _value('respiratory_rate'),
                                    'breaths/min',
                                    Icons.air_rounded,
                                    AppColors.teal),
                                _Vital(
                                    'Heart rate',
                                    _value('heart_rate'),
                                    'bpm',
                                    Icons.favorite_rounded,
                                    AppColors.coral),
                                _Vital(
                                    'SPO2 (room air)',
                                    _value('spo2_room_air'),
                                    '%',
                                    Icons.water_drop_rounded,
                                    AppColors.sky),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TcCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl,
                                  vertical: AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Care checklist',
                                      style: AppType.eyebrow),
                                  const SizedBox(height: AppSpacing.sm),
                                  _YesNoRow('Daily dressing done',
                                      _value('daily_dressing_done')),
                                  _YesNoRow('Tracheostomy tie changed',
                                      _value('tracheostomy_tie_changed')),
                                  _YesNoRow('Suctioning done',
                                      _value('suctioning_done')),
                                  if (_value('suctioning_done') == 'Yes')
                                    TcDetailRow(
                                        label: 'Secretion colour & consistency',
                                        value: _value(
                                            'secretion_color_consistency')),
                                  _YesNoRow('Started on oral feeds',
                                      _value('oral_feeds_started')),
                                  if (_value('oral_feeds_started') == 'Yes')
                                    _YesNoRow('Cough or breathlessness',
                                        _value('cough_or_breathlessness')),
                                  _YesNoRow('Changed to green tube',
                                      _value('changed_to_green_tube')),
                                  _YesNoRow(
                                      'Breathes through nose with tube blocked',
                                      _value('able_to_breathe_through_nose')),
                                  if (_value('able_to_breathe_through_nose') ==
                                      'Yes')
                                    TcDetailRow(
                                      label: 'Breath duration',
                                      value: '${_value('breath_duration')} min',
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _Vital {
  const _Vital(this.label, this.value, this.unit, this.icon, this.color);

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
}

class _VitalRow extends StatelessWidget {
  const _VitalRow({required this.vitals});

  final List<_Vital> vitals;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < vitals.length; i++) ...[
          Expanded(
            child: TcCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: vitals[i].color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child:
                        Icon(vitals[i].icon, size: 18, color: vitals[i].color),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FittedBox(
                    child: Text(
                      vitals[i].value.isEmpty ? '—' : vitals[i].value,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: vitals[i].color),
                    ),
                  ),
                  Text(
                    vitals[i].unit,
                    style: const TextStyle(
                        fontSize: 9.5, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    vitals[i].label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkBody),
                  ),
                ],
              ),
            ),
          ),
          if (i != vitals.length - 1) const SizedBox(width: AppSpacing.md),
        ],
      ],
    );
  }
}

class _YesNoRow extends StatelessWidget {
  const _YesNoRow(this.label, this.answer);

  final String label;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final yes = answer == 'Yes';
    final no = answer == 'No';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.inkBody)),
          ),
          const SizedBox(width: AppSpacing.md),
          TcBadge(
            label: yes
                ? 'Yes'
                : no
                    ? 'No'
                    : 'Not recorded',
            color: yes
                ? AppColors.success
                : no
                    ? AppColors.danger
                    : AppColors.inkMuted,
            background: yes
                ? AppColors.successSoft
                : no
                    ? AppColors.dangerSoft
                    : AppColors.surfaceAlt,
            icon: yes
                ? Icons.check_rounded
                : no
                    ? Icons.close_rounded
                    : Icons.remove_rounded,
          ),
        ],
      ),
    );
  }
}

class _ReportSkeleton extends StatelessWidget {
  const _ReportSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: const [
        TcSkeleton(height: 86, radius: 20),
        SizedBox(height: AppSpacing.lg),
        TcSkeleton(height: 132, radius: 20),
        SizedBox(height: AppSpacing.lg),
        TcSkeleton(height: 300, radius: 20),
      ],
    );
  }
}
