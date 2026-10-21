import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/Screens/Views/patient/patientscreens/reminders.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/services/care_insights.dart';
import 'package:trachcare/services/reminder_service.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

/// Streak, adherence and the reminder entry point, in one card.
///
/// Reads the same `dailyreport` rows the calendar screen already pulls, so it
/// costs one request and no schema change.
class CarePulseCard extends StatefulWidget {
  const CarePulseCard({super.key, required this.patientName});

  final String patientName;

  @override
  State<CarePulseCard> createState() => _CarePulseCardState();
}

class _CarePulseCardState extends State<CarePulseCard> {
  List<dynamic> _reports = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await http
          .get(Uri.parse('$dailyreport?patient_id=$patient_id'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (mounted && decoded is List) {
          setState(() {
            _reports = decoded;
            _loading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('CarePulseCard: report history unavailable ($e)');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final dates = _reports
        .map((r) => r is Map ? '${r['date'] ?? ''}' : null)
        .toList(growable: false);
    final streak = careStreak(dates);
    final adherence = adherencePercent(dates);
    final armed = ReminderService.instance.buildSchedule().length;

    return TcCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RemindersPage()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Your care rhythm', style: AppType.eyebrow),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: AppSize.s(20), color: AppColors.inkMuted),
            ],
          ),
          SizedBox(height: AppSize.s(10)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AdherenceRing(percent: adherence, loading: _loading),
              SizedBox(width: AppSize.s(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streak == 0
                          ? 'Start today’s report'
                          : '$streak day${streak == 1 ? '' : 's'} in a row',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: AppSize.s(17),
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: AppSize.s(3)),
                    Text(
                      _loading
                          ? 'Checking your history…'
                          : '$adherence% of the last 7 days filed · $armed reminders armed',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.inkMuted),
                    ),
                    SizedBox(height: AppSize.s(10)),
                    Text(
                      'Tap to choose which messages ${widget.patientName.isEmpty ? 'you' : widget.patientName} receives',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: AppSize.s(12),
                        fontWeight: FontWeight.w700,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdherenceRing extends StatelessWidget {
  const _AdherenceRing({required this.percent, required this.loading});

  final int percent;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final value = loading ? 0.0 : (percent / 100).clamp(0.0, 1.0);
    return SizedBox(
      width: AppSize.s(62),
      height: AppSize.s(62),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: AppSize.s(6),
            strokeCap: StrokeCap.round,
            backgroundColor: AppColors.surfaceAlt,
            color: value >= 0.7 ? AppColors.success : AppColors.amber,
          ),
          Text(
            loading ? '—' : '$percent%',
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSize.s(13),
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
