import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/json_client.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/roster_screen.dart';
import 'package:trachcare/style/design_system.dart';

import 'doctordetails.dart';

class Doctorlist extends StatelessWidget {
  const Doctorlist({super.key});

  @override
  Widget build(BuildContext context) {
    return TcRosterScreen(
      title: 'Medical team',
      subtitle: 'Clinicians with clinic access',
      searchHint: 'Search doctors by name',
      emptyTitle: 'No doctors yet',
      emptyMessage: 'Add a clinician from the Add doctor tab.',
      fallbackIcon: Icons.local_hospital_rounded,
      load: () => fetchJson(DoctorslistUrl),
      entries: (raw) => [
        for (final item in rowsOf(raw))
          TcRosterEntry(
            key: item['doctor_id'].toString(),
            title: item['username'].toString(),
            id: 'Doctor ID ${item['doctor_id']}',
            imagePath: trachcareAsset(item['image_path']?.toString()),
            chip: 'Open',
            chipColor: AppColors.teal,
            chipSoft: AppColors.mintSoft,
          ),
      ],
      onEntryTap: (entry) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => Doctordetails(Doctor_id: entry.key),
        ));
      },
    );
  }
}
