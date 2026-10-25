import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/json_client.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/roster_screen.dart';
import 'package:trachcare/style/design_system.dart';

import 'ViewPatientDetails.dart';

class patients_list extends StatelessWidget {
  const patients_list({super.key});

  @override
  Widget build(BuildContext context) {
    return TcRosterScreen(
      title: 'Patients',
      subtitle: 'Everyone enrolled in the clinic',
      searchHint: 'Search patients by name',
      emptyTitle: 'No patients yet',
      emptyMessage: 'Doctors add patients from their console.',
      fallbackIcon: Icons.medical_information_rounded,
      load: () => fetchJson(allpatientslistUrl),
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
