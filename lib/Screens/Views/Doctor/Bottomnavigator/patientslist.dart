import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/json_client.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/components/roster_screen.dart';
import 'package:trachcare/services/care_insights.dart';
import 'package:trachcare/style/design_system.dart';

import '../doctorscreens/Patientsdetails.dart';

/// The doctor's own patients — also pushed when a chart screen pops back.
/// Scoped to the signed-in doctor; the admin-wide roster must never be
/// reachable from this tab.
///
/// Each row also carries the flag from that patient's most recent report, so
/// the list orders itself by what needs attention rather than by name.
class patientslist extends StatelessWidget {
  const patientslist({super.key, this.embedded = false});

  /// True inside the doctor shell, which already draws the app bar.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return TcRosterScreen(
      embedded: embedded,
      title: 'My patients',
      subtitle: 'Everyone you are currently following',
      load: () async {
        final patients =
            await fetchJson('$PatientslistUrl?doctor_id=$Doctor_id');
        final reports = await fetchJsonOrEmpty(
            '$flaggedReportsUrl?doctor_id=$Doctor_id&days=3');
        return {'patients': patients, 'reports': reports};
      },
      entries: (raw) {
        final flags = _latestFlags(rowsOf(raw is Map ? raw['reports'] : null));
        final rows = rowsOf(raw is Map ? raw['patients'] : raw);
        final ranked = [
          for (final item in rows) _ranked(item, flags['${item['patient_id']}']),
        ]..sort((a, b) => a.$1.compareTo(b.$1));
        return [for (final (_, entry) in ranked) entry];
      },
      onEntryTap: (entry) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PatientDetails(patientId: entry.key),
        ),
      ),
    );
  }
}

/// patient_id -> the flag that should surface today, newest report wins.
Map<String, List<RedFlag>> _latestFlags(List<dynamic> reports) {
  final newest = <String, Map<String, dynamic>>{};
  for (final row in reports.whereType<Map<String, dynamic>>()) {
    final id = '${row['patient_id']}';
    final held = newest[id];
    if (held == null ||
        '${row['date']}'.compareTo('${held['date']}') >= 0) {
      newest[id] = row;
    }
  }
  return {
    for (final entry in newest.entries) entry.key: redFlags(entry.value),
  };
}

/// Danger first, then warnings, then the quiet rest of the panel.
(int, TcRosterEntry) _ranked(dynamic item, List<RedFlag>? flags) {
  final danger = flags?.any((f) => f.isDanger) ?? false;
  final warning = flags?.isNotEmpty ?? false;

  return (
    danger ? 0 : warning ? 1 : 2,
    TcRosterEntry(
      key: item['patient_id'].toString(),
      title: item['username'].toString(),
      id: 'Patient ID ${item['patient_id']}',
      imagePath: trachcareAsset(item['image_path']?.toString()),
      chip: danger || warning ? flags!.first.label : 'Chart',
      chipSoft: danger
          ? AppColors.dangerSoft
          : warning
              ? AppColors.amberSoft
              : AppColors.skySoft,
      chipColor: danger
          ? AppColors.danger
          : warning
              ? AppColors.warning
              : AppColors.sky,
    ),
  );
}
