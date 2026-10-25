import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/quotes.dart';
import 'package:trachcare/services/reminder_service.dart';

void main() {
  group('quotes', () {
    test('randomQuote returns an entry from the list', () {
      for (var i = 0; i < 50; i++) {
        expect(motivationalQuotes, contains(randomQuote()));
      }
    });

    test('randomQuote varies across calls', () {
      final rnd = Random(42);
      final seen = {for (var i = 0; i < 30; i++) randomQuote(rnd).text};
      expect(seen.length, greaterThan(1));
    });

    test('startPatientSession assigns a fresh session quote', () {
      sessionQuote = null;
      startPatientSession();
      expect(sessionQuote, isNotNull);
      expect(motivationalQuotes, contains(sessionQuote));
    });
  });

  group('trachcareAsset', () {
    test('strips leading ./ and ../ prefixes', () {
      expect(trachcareAsset('./uploads/a.png'), '$apiBase/uploads/a.png');
      expect(trachcareAsset('../uploads/a.png'), '$apiBase/uploads/a.png');
      expect(trachcareAsset('../../uploads/a.png'), '$apiBase/uploads/a.png');
    });

    test('handles empty, null and absolute URLs safely', () {
      expect(trachcareAsset(null), '');
      expect(trachcareAsset(''), '');
      expect(trachcareAsset('http://x/y.png'), 'http://x/y.png');
    });
  });

  group('ReminderToggles', () {
    test('all groups enabled by default', () {
      const t = ReminderToggles();
      for (final g in ReminderGroup.values) {
        expect(t.isEnabled(g), isTrue);
      }
    });

    test('json round-trip keeps settings', () {
      const t = ReminderToggles(
        groupOff: {'meals': true},
        morningAfter: true,
        nightAfter: true,
      );
      final back = ReminderToggles.fromJson(t.toJson());
      expect(back.isEnabled(ReminderGroup.meals), isFalse);
      expect(back.isEnabled(ReminderGroup.medication), isTrue);
      expect(back.morningAfter, isTrue);
      expect(back.nightAfter, isTrue);
      expect(back.morningBefore, isTrue);
    });
  });

  group('ReminderService.buildSchedule', () {
    test('fires healthy meal nudges at 08:00, 13:00 and 20:00', () {
      final meals = ReminderService.instance
          .buildSchedule()
          .where((r) => r.group == ReminderGroup.meals)
          .toList();
      expect(meals, hasLength(3));
      expect(meals.map((m) => m.hour).toList(), [8, 13, 20]);
      for (final m in meals) {
        expect(m.minute, 0);
        expect(m.body, isNotEmpty);
      }
    });

    test('schedule stays within a day and ids are unique', () {
      final slots = ReminderService.instance.buildSchedule();
      expect(slots.map((s) => s.id).toSet(), hasLength(slots.length));
      for (final s in slots) {
        expect(s.hour, inInclusiveRange(0, 23));
        expect(s.minute, inInclusiveRange(0, 59));
      }
    });
  });
}
