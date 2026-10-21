import 'package:flutter/material.dart';
import 'package:trachcare/Screens/Views/Admin/Adminscreens/calender.dart';
import 'package:trachcare/Screens/Views/Doctor/doctorscreens/Patientsdetails.dart';

/// Admin's patient chart. The record itself is identical for every role, so
/// this reuses the doctor's screen and only swaps in the admin history calendar.
class ViewPatientDetails extends StatelessWidget {
  final String patientId;

  const ViewPatientDetails({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return PatientDetails(
      patientId: patientId,
      history: (id, name, imagePath) => a_CalendarScreen(
        patientId: id,
        name: name,
        imagePath: imagePath,
      ),
    );
  }
}
