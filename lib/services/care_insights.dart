/// Pure rules over the rows the app already fetches.
///
/// Both features read `daily_report`, which the backend returns in full, so
/// neither needs a new endpoint — and the logic is testable without a device.
library;

/// Consecutive days, ending today or yesterday, that a report was filed.
///
/// A streak that broke yesterday still counts, otherwise the number resets at
/// the first midnight a patient is asleep and stops meaning anything.
int careStreak(Iterable<String?> reportDates, {DateTime? today}) {
  final days = <DateTime>{};
  for (final raw in reportDates) {
    if (raw == null || raw.isEmpty) continue;
    final parsed = DateTime.tryParse(raw.split(' ').first);
    if (parsed != null) {
      days.add(DateTime(parsed.year, parsed.month, parsed.day));
    }
  }
  if (days.isEmpty) return 0;

  final now = today ?? DateTime.now();
  var cursor = DateTime(now.year, now.month, now.day);
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
  }

  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

/// Percentage of the last [window] days that carry a report.
int adherencePercent(Iterable<String?> reportDates, {int window = 7, DateTime? today}) {
  final now = today ?? DateTime.now();
  final days = <DateTime>{};
  for (var i = 0; i < window; i++) {
    days.add(DateTime(now.year, now.month, now.day).subtract(Duration(days: i)));
  }
  final filed = reportDates.whereType<String>().where((d) {
    final parsed = DateTime.tryParse(d.split(' ').first);
    if (parsed == null) return false;
    final day = DateTime(parsed.year, parsed.month, parsed.day);
    return days.contains(day);
  }).length;
  return ((filed / window) * 100).round();
}

enum FlagSeverity { danger, warning }

/// One reason a chart should jump the queue on the clinician's screen.
class RedFlag {
  const RedFlag(this.label, this.detail, this.severity);

  final String label;
  final String detail;
  final FlagSeverity severity;

  bool get isDanger => severity == FlagSeverity.danger;
}

/// Turns a submitted report into the reasons a clinician should look today.
///
/// Thresholds are the usual tracheostomy ward escalation limits: SpO₂ under
/// 94%, a respiratory rate outside 12–24, a heart rate outside 50–120, and any
/// answer that says a care step was skipped.
List<RedFlag> redFlags(Map<String, dynamic>? report) {
  if (report == null || report.isEmpty) return const [];
  final flags = <RedFlag>[];

  double? num(String key) => double.tryParse('${report[key] ?? ''}');
  String yes(String key) => '${report[key] ?? ''}'.trim();

  final spo2 = num('spo2_room_air');
  if (spo2 != null && spo2 < 94) {
    flags.add(RedFlag(
      'Low SpO₂',
      '${spo2.toStringAsFixed(0)}% on room air',
      FlagSeverity.danger,
    ));
  }

  final rr = num('respiratory_rate');
  if (rr != null && (rr > 24 || rr < 12)) {
    flags.add(RedFlag(
      'Breathing rate',
      '${rr.toStringAsFixed(0)} breaths/min',
      FlagSeverity.warning,
    ));
  }

  final hr = num('heart_rate');
  if (hr != null && (hr > 120 || hr < 50)) {
    flags.add(RedFlag(
      'Heart rate',
      '${hr.toStringAsFixed(0)} bpm',
      FlagSeverity.warning,
    ));
  }

  if (yes('cough_or_breathlessness').toLowerCase() == 'yes') {
    flags.add(const RedFlag(
      'Cough or breathlessness',
      'Reported in today’s daily queries',
      FlagSeverity.warning,
    ));
  }

  final secretion = yes('secretion_color_consistency').toLowerCase();
  if (secretion.contains('green') ||
      secretion.contains('brown') ||
      secretion.contains('blood')) {
    flags.add(RedFlag(
      'Secretion change',
      yes('secretion_color_consistency'),
      FlagSeverity.danger,
    ));
  }

  for (final step in const {
    'daily_dressing_done': 'Dressing',
    'tracheostomy_tie_changed': 'Tie change',
    'suctioning_done': 'Suctioning',
  }.entries) {
    if (yes(step.key).toLowerCase() == 'no') {
      flags.add(RedFlag(
        '${step.value} skipped',
        'Marked No on the daily report',
        FlagSeverity.warning,
      ));
    }
  }

  return flags;
}

/// True when no report exists for [day] — a missing entry is itself a signal.
bool reportMissingFor(DateTime day, Iterable<String?> reportDates) {
  final target = DateTime(day.year, day.month, day.day);
  return !reportDates.whereType<String>().any((raw) {
    final parsed = DateTime.tryParse(raw.split(' ').first);
    if (parsed == null) return false;
    return DateTime(parsed.year, parsed.month, parsed.day) == target;
  });
}
