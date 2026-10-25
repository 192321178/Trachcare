import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trachcare/Screens/Views/patient/Bottomnavigationscreens/Medication.dart';
import 'package:trachcare/Screens/Views/patient/Bottomnavigationscreens/PatientDashborad.dart';
import 'package:trachcare/Screens/Views/patient/Bottomnavigationscreens/video_list.dart';
import 'package:trachcare/components/ui_kit.dart';

class PatientMainScreen extends StatefulWidget {
  /// Which tab to open first — deep flows (daily updates, calendar back,
  /// spigotting sheet) push this shell so the bottom nav is never lost.
  final int initialIndex;

  /// After a fresh login, remind the patient to file today's report once the
  /// dashboard is on screen — the dialog is shown from this screen's own
  /// context, not the login page's (which is destroyed by the navigation).
  final bool promptDailyReport;

  const PatientMainScreen({
    super.key,
    this.initialIndex = 0,
    this.promptDailyReport = false,
  });

  @override
  State<PatientMainScreen> createState() => _PatientMainScreenState();
}

class _PatientMainScreenState extends State<PatientMainScreen> {
  late int _index = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    if (widget.promptDailyReport) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showCupertinoModalPopup<void>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Daily Report'),
            content:
                const Text('Kindly update your Daily Queries first!!!.'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context, 'Ok'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

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
