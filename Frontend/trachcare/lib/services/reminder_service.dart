import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// One timed message the phone should deliver on its own.
///
/// [hour]/[minute] are wall-clock in the patient's own timezone, and
/// [daily] slots repeat every day at that time.
class CareReminder {
  const CareReminder({
    required this.id,
    required this.group,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
  });

  final int id;
  final ReminderGroup group;
  final String title;
  final String body;
  final int hour;
  final int minute;

  String get clock =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// The families of message TrachCare sends. Each is independently switchable
/// so a patient who is weaned off tablets does not keep being pinged.
enum ReminderGroup {
  medication('Medication', 'Pill times, placed around your meals'),
  airway('Airway clearance', 'Spigotting and clapping checks'),
  report('Daily report', 'One nudge before bed'),
  therapy('Therapy session', 'Your prescribed video for today');

  const ReminderGroup(this.label, this.blurb);
  final String label;
  final String blurb;
}

/// Which slots within a group are live.
class ReminderToggles {
  const ReminderToggles({
    this.groupOff = const {},
    this.morningBefore = true,
    this.morningAfter = false,
    this.afternoonBefore = true,
    this.afternoonAfter = false,
    this.nightBefore = true,
    this.nightAfter = false,
  });

  /// Group name -> disabled.
  final Map<String, bool> groupOff;

  /// The six medication slots map 1:1 onto `medication_schedule`'s columns, so
  /// a doctor's prescription drives what the phone actually says.
  final bool morningBefore;
  final bool morningAfter;
  final bool afternoonBefore;
  final bool afternoonAfter;
  final bool nightBefore;
  final bool nightAfter;

  bool isEnabled(ReminderGroup group) => groupOff[group.name] != true;

  ReminderToggles copyWith({
    Map<String, bool>? groupOff,
    bool? morningBefore,
    bool? morningAfter,
    bool? afternoonBefore,
    bool? afternoonAfter,
    bool? nightBefore,
    bool? nightAfter,
  }) =>
      ReminderToggles(
        groupOff: groupOff ?? this.groupOff,
        morningBefore: morningBefore ?? this.morningBefore,
        morningAfter: morningAfter ?? this.morningAfter,
        afternoonBefore: afternoonBefore ?? this.afternoonBefore,
        afternoonAfter: afternoonAfter ?? this.afternoonAfter,
        nightBefore: nightBefore ?? this.nightBefore,
        nightAfter: nightAfter ?? this.nightAfter,
      );

  Map<String, Object> toJson() => {
        'off': groupOff.map((k, v) => MapEntry(k, v)),
        'mb': morningBefore,
        'ma': morningAfter,
        'ab': afternoonBefore,
        'aa': afternoonAfter,
        'nb': nightBefore,
        'na': nightAfter,
      };

  static ReminderToggles fromJson(Object? raw) {
    if (raw is! Map) return const ReminderToggles();
    final off = <String, bool>{};
    (raw['off'] as Map?)?.forEach((k, v) => off['$k'] = v == true);
    return ReminderToggles(
      groupOff: off,
      morningBefore: raw['mb'] != false,
      morningAfter: raw['ma'] == true,
      afternoonBefore: raw['ab'] != false,
      afternoonAfter: raw['aa'] == true,
      nightBefore: raw['nb'] != false,
      nightAfter: raw['na'] == true,
    );
  }
}

/// Meal anchors the medication slots hang off.
///
/// A tracheostomy patient's tablets are prescribed relative to food rather than
/// to a clock, so the schedule stores "before/after breakfast" and the phone
/// turns that into a time. 08:00 / 13:00 / 20:00 are the clinic defaults.
const _meals = {
  'morning': 8 * 60,
  'afternoon': 13 * 60,
  'night': 20 * 60,
};

/// 30 minutes before a meal the stomach is empty; 45 after it is settled.
const _beforeLead = 30;
const _afterLead = 45;

/// Builds and delivers the patient's daily message schedule.
///
/// Everything here is on-device: `flutter_local_notifications` hands the slots
/// to Android's AlarmManager, so reminders fire with the app closed and
/// survive a reboot through the boot receiver in AndroidManifest. Nothing
/// depends on the clinic server being reachable, which is what makes the
/// feature usable on a patient's own handset.
class ReminderService {
  ReminderService._();

  static final ReminderService instance = ReminderService._();

  static const _channelId = 'trachcare.care';
  static const _channelName = 'Care reminders';
  static const _togglesKey = 'trachcare.reminderToggles';
  static const _nameKey = 'trachcare.patientName';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;
  String _patientName = '';
  ReminderToggles _toggles = const ReminderToggles();

  ReminderToggles get toggles => _toggles;
  String get patientName => _patientName;

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _alignToDeviceInfoZone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (_) {},
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Medication, airway and report reminders',
            importance: Importance.high,
          ),
        );

    // Android 13 gates notifications behind a runtime prompt. Asking here, on
    // first launch, beats asking again the moment a patient opens the
    // Reminders screen and expects their pills to be covered.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final prefs = await SharedPreferences.getInstance();
    _patientName = prefs.getString(_nameKey) ?? '';
    final raw = prefs.getString(_togglesKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _toggles = ReminderToggles.fromJson(jsonDecode(raw));
      } catch (e) {
        debugPrint('ReminderService: stored toggles unreadable, using defaults');
      }
    }
    _ready = true;
  }

  /// Android 12+ can hand back a fixed offset instead of an IANA name, which
  /// `tz.getLocation` rejects. Fall back to UTC rather than throwing away the
  /// whole schedule.
  Future<void> _alignToDeviceInfoZone() async {
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e) {
      debugPrint('ReminderService: timezone unresolved, using UTC ($e)');
    }
  }

  Future<void> setPatientName(String name) async {
    await init();
    if (name.trim() == _patientName) return;
    _patientName = name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _patientName);
    await apply();
  }

  Future<void> setGroupEnabled(ReminderGroup group, bool enabled) async {
    await init();
    final off = Map<String, bool>.from(_toggles.groupOff);
    off[group.name] = !enabled;
    await _persist(_toggles.copyWith(groupOff: off));
  }

  Future<void> setMedicationSlot(
    String slot,
    bool before,
    bool enabled,
  ) async {
    await init();
    final key = '${slot}_${before ? 'before' : 'after'}';
    final values = {
      'morning_before': _toggles.morningBefore,
      'morning_after': _toggles.morningAfter,
      'afternoon_before': _toggles.afternoonBefore,
      'afternoon_after': _toggles.afternoonAfter,
      'night_before': _toggles.nightBefore,
      'night_after': _toggles.nightAfter,
      key: enabled,
    };
    await _persist(ReminderToggles(
      groupOff: _toggles.groupOff,
      morningBefore: values['morning_before']!,
      morningAfter: values['morning_after']!,
      afternoonBefore: values['afternoon_before']!,
      afternoonAfter: values['afternoon_after']!,
      nightBefore: values['night_before']!,
      nightAfter: values['night_after']!,
    ));
  }

  /// Adopt the doctor's prescription verbatim — the six booleans on
  /// `medication_schedule` become the six live slots.
  Future<void> applyMedicationPlan({
    required bool morningBefore,
    required bool morningAfter,
    required bool afternoonBefore,
    required bool afternoonAfter,
    required bool nightBefore,
    required bool nightAfter,
  }) async {
    await init();
    await _persist(ReminderToggles(
      groupOff: _toggles.groupOff,
      morningBefore: morningBefore,
      morningAfter: morningAfter,
      afternoonBefore: afternoonBefore,
      afternoonAfter: afternoonAfter,
      nightBefore: nightBefore,
      nightAfter: nightAfter,
    ));
  }

  Future<void> _persist(ReminderToggles next) async {
    _toggles = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_togglesKey, jsonEncode(next.toJson()));
    await apply();
  }

  /// Pure, so the time arithmetic is testable without a device.
  List<CareReminder> buildSchedule() {
    final name = _patientName.isEmpty ? 'there' : _patientName;
    final slots = <CareReminder>[];

    if (_toggles.isEnabled(ReminderGroup.medication)) {
      void med(String slot, String label, bool before, bool on, int id) {
        if (!on) return;
        final minutes = _meals[slot]! + (before ? -_beforeLead : _afterLead);
        slots.add(CareReminder(
          id: id,
          group: ReminderGroup.medication,
          title: before ? 'Tablet time, $name' : 'After your $label meal',
          body: before
              ? 'Take your $label tablet $_beforeLead minutes before you eat.'
              : 'Now is the right time for your $label tablet.',
          hour: (minutes ~/ 60) % 24,
          minute: minutes % 60,
        ));
      }

      med('morning', 'morning', true, _toggles.morningBefore, 101);
      med('morning', 'breakfast', false, _toggles.morningAfter, 102);
      med('afternoon', 'lunch', true, _toggles.afternoonBefore, 103);
      med('afternoon', 'lunch', false, _toggles.afternoonAfter, 104);
      med('night', 'dinner', true, _toggles.nightBefore, 105);
      med('night', 'dinner', false, _toggles.nightAfter, 106);
    }

    if (_toggles.isEnabled(ReminderGroup.airway)) {
      // Fires at the opening of each spigotting window the doctor already
      // tracks in `daily_stauts` — the same five slots the dashboard draws.
      const checks = [
        (10, 0),
        (12, 0),
        (14, 0),
        (16, 0),
        (18, 0),
      ];
      for (var i = 0; i < checks.length; i++) {
        slots.add(CareReminder(
          id: 201 + i,
          group: ReminderGroup.airway,
          title: 'Airway check, $name',
          body: 'Spigotting and clapping take two minutes. Log it when done.',
          hour: checks[i].$1,
          minute: checks[i].$2,
        ));
      }
    }

    if (_toggles.isEnabled(ReminderGroup.report)) {
      slots.add(CareReminder(
        id: 301,
        group: ReminderGroup.report,
        title: 'Daily report, $name',
        body: 'Two minutes now keeps your doctor’s evening clear.',
        hour: 21,
        minute: 30,
      ));
    }

    if (_toggles.isEnabled(ReminderGroup.therapy)) {
      slots.add(CareReminder(
        id: 401,
        group: ReminderGroup.therapy,
        title: 'Breathing session, $name',
        body: 'Your prescribed video is waiting in WatchZone.',
        hour: 18,
        minute: 0,
      ));
    }

    return slots;
  }

  /// Re-arm every slot for the coming days and drop anything stale.
  Future<void> apply() async {
    await init();
    for (final slot in buildSchedule()) {
      await _plugin.cancel(slot.id);
    }
    if (_patientName.isEmpty) return;
    for (final slot in buildSchedule()) {
      try {
        await _plugin.zonedSchedule(
          slot.id,
          slot.title,
          slot.body,
          _nextInstanceOf(slot.hour, slot.minute),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: 'Medication, airway and report reminders',
              importance: Importance.high,
              priority: Priority.high,
              styleInformation: BigTextStyleInformation(''),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e) {
        debugPrint('ReminderService: could not arm ${slot.id} ($e)');
      }
    }
  }

  /// The next occurrence strictly after now — scheduling a time that already
  /// passed today fires the notification the instant the app starts.
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now.add(const Duration(seconds: 20)))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}
