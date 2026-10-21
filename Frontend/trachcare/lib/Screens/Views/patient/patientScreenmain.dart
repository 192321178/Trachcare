import 'package:flutter/material.dart';
import 'package:trachcare/Screens/Views/patient/Bottomnavigationscreens/Medication.dart';
import 'package:trachcare/Screens/Views/patient/Bottomnavigationscreens/PatientDashborad.dart';
import 'package:trachcare/Screens/Views/patient/Bottomnavigationscreens/video_list.dart';
import 'package:trachcare/components/ui_kit.dart';

class PatientMainScreen extends StatefulWidget {
  const PatientMainScreen({super.key});

  @override
  State<PatientMainScreen> createState() => _PatientMainScreenState();
}

class _PatientMainScreenState extends State<PatientMainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: const [
          PatientDashBoard(),
          Videospage(),
          MedicationPage(),
        ],
      ),
      bottomNavigationBar: TcNavBar(
        currentIndex: _index,
        onSelected: (i) => setState(() => _index = i),
        items: const [
          TcNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
          ),
          TcNavItem(
            icon: Icons.play_circle_outline_rounded,
            activeIcon: Icons.play_circle_rounded,
            label: 'Therapy',
          ),
          TcNavItem(
            icon: Icons.medication_liquid_outlined,
            activeIcon: Icons.medication_liquid_rounded,
            label: 'Records',
          ),
        ],
      ),
    );
  }
}
