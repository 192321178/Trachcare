import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/json_client.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/roster_screen.dart';
import 'package:trachcare/style/design_system.dart';

import 'ViewPatientDetails.dart';

/// The patients assigned to one doctor. Named `patientlist copy` on disk
/// because it was forked from the clinic-wide list; the behaviour here is the
/// doctor-scoped one it was always meant to be.
class patientlist extends StatelessWidget {
  final String doctor_id;

  const patientlist({super.key, required this.doctor_id});

  @override
  Widget build(BuildContext context) {
    return TcRosterScreen(
      title: 'Their patients',
      subtitle: 'Caseload for this clinician',
      searchHint: 'Search patients by name',
      emptyTitle: 'No patients assigned',
      emptyMessage: 'This doctor has not enrolled anyone yet.',
      fallbackIcon: Icons.medical_information_rounded,
      load: () => fetchJson('$PatientslistUrl?doctor_id=$doctor_id'),
      entries: (raw) => [
        for (final item in rowsOf(raw))
          TcRosterEntry(
            key: item['patient_id'].toString(),
            title: item['username'].toString(),
            id: 'Patient ID ${item['patient_id']}',
            imagePath: trachcareAsset(item['image_path']?.toString()),
            chip: 'Record',
            chipColor: AppColors.sky,
            chipSoft: AppColors.skySoft,
          ),
      ],
      onEntryTap: (entry) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ViewPatientDetails(patientId: entry.key),
        ));
      },
    );
  }
}
