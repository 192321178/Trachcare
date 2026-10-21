import 'package:flutter_test/flutter_test.dart';
import 'package:trachcare/services/care_insights.dart';

void main() {
  group('care streak', () {
    final today = DateTime(2026, 10, 20);

    test('counts back through consecutive days including today', () {
      expect(
        careStreak(
          ['2026-10-20', '2026-10-19', '2026-10-18'],
          today: today,
        ),
        3,
      );
    });

    test('a gap ends the run', () {
      expect(
        careStreak(['2026-10-20', '2026-10-18'], today: today),
        1,
      );
    });

    test('yesterday keeps the streak alive overnight', () {
      expect(careStreak(['2026-10-19', '2026-10-18'], today: today), 2);
    });

    test('nothing filed is zero, not an error', () {
      expect(careStreak([null, ''], today: today), 0);
    });

    test('a timestamp with a time component still parses', () {
      expect(careStreak(['2026-10-20 13:46:46'], today: today), 1);
    });
  });

  group('adherence', () {
    final today = DateTime(2026, 10, 20);

    test('is a percentage over a seven day window', () {
      expect(
        adherencePercent(
          ['2026-10-20', '2026-10-19', '2026-10-18'],
          today: today,
        ),
        43,
      );
    });

    test('ignores reports older than the window', () {
      expect(adherencePercent(['2026-09-01'], today: today), 0);
    });
  });

  group('red flags', () {
    test('low oxygen on room air is a danger', () {
      final flags = redFlags({'spo2_room_air': '89'});
      expect(flags.single.label, 'Low SpO₂');
      expect(flags.single.isDanger, isTrue);
    });

    test('oxygen at the threshold is not flagged', () {
      expect(redFlags({'spo2_room_air': '94'}), isEmpty);
    });

    test('a skipped care step is a warning', () {
      final flags = redFlags({'suctioning_done': 'No'});
      expect(flags.single.label, 'Suctioning skipped');
      expect(flags.single.isDanger, isFalse);
    });

    test('discoloured secretion outranks a skipped step', () {
      final flags = redFlags({
        'secretion_color_consistency': 'Thick green',
        'daily_dressing_done': 'No',
      });
      expect(flags.first.label, 'Secretion change');
      expect(flags.first.isDanger, isTrue);
    });

    test('breathing rate flags in both directions', () {
      expect(redFlags({'respiratory_rate': '30'}), isNotEmpty);
      expect(redFlags({'respiratory_rate': '9'}), isNotEmpty);
      expect(redFlags({'respiratory_rate': '18'}), isEmpty);
    });

    test('a clean report raises nothing', () {
      expect(
        redFlags({
          'spo2_room_air': '97',
          'respiratory_rate': '16',
          'heart_rate': '78',
          'cough_or_breathlessness': 'No',
          'daily_dressing_done': 'Yes',
          'tracheostomy_tie_changed': 'Yes',
          'suctioning_done': 'Yes',
        }),
        isEmpty,
      );
    });

    test('a missing row cannot invent a flag', () {
      expect(redFlags(null), isEmpty);
      expect(redFlags({}), isEmpty);
    });
  });

  group('missing report', () {
    test('spots a day with no entry', () {
      expect(
        reportMissingFor(DateTime(2026, 10, 20), ['2026-10-19']),
        isTrue,
      );
      expect(
        reportMissingFor(DateTime(2026, 10, 20), ['2026-10-20 09:00']),
        isFalse,
      );
    });
  });
}
