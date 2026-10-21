import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/DashboardApi.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/Appbar.dart';
import 'package:trachcare/components/Navbardrawer.dart';
import 'package:trachcare/components/ui_kit.dart';

import 'Bottomnavigator/Doctorsdashboard.dart';
import 'Bottomnavigator/patientslist.dart';
import 'doctorscreens/doctorprofile.dart';
import 'doctorscreens/videolist.dart';

/// Doctor shell: one profile request, one app bar, one drawer, one nav bar.
/// The three tab bodies below render content only.
class Doctormainpage extends StatefulWidget {
  const Doctormainpage({super.key});

  @override
  State<Doctormainpage> createState() => _DoctormainpageState();
}

class _DoctormainpageState extends State<Doctormainpage> {
  late Future<dynamic> _profile = DoctorDashBoardApi().FetchDetials();
  int _index = 0;

  Future<void> _refreshProfile() async {
    setState(() => _profile = DoctorDashBoardApi().FetchDetials());
    await _profile;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _profile,
      builder: (context, snapshot) {
        final info = snapshot.data?['Dashboard'];
        final status = snapshot.data?['status'];
        final alerts = status is List ? status : const [];
        final name = info?['username']?.toString() ?? 'Doctor';
        final regNo = info?['doctor_reg_no']?.toString() ?? '';

        return Scaffold(
          extendBody: true,
          appBar: Appbar(
            doctor: true,
            Name: name,
            height: 92,
            notification: alerts.isNotEmpty,
            notificationlists: alerts,
          ),
          drawer: drawer(
            Name: name,
            reg_no: regNo,
            imagepath:
                NetworkImage(trachcareAsset(info?['image_path']?.toString())),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => d_ProfilePage()))
                  .then((_) => _refreshProfile());
            },
          ),
          body: IndexedStack(
            index: _index,
            children: [
              DoctorDashBoard(
                onOpenTab: (i) => setState(() => _index = i),
              ),
              const Videolist(),
              const patientslist(embedded: true),
            ],
          ),
          bottomNavigationBar: TcNavBar(
            currentIndex: _index,
            onSelected: (i) => setState(() => _index = i),
            items: const [
              TcNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Overview',
              ),
              TcNavItem(
                icon: Icons.video_library_outlined,
                activeIcon: Icons.video_library_rounded,
                label: 'Videos',
              ),
              TcNavItem(
                icon: Icons.groups_outlined,
                activeIcon: Icons.groups_rounded,
                label: 'Patients',
              ),
            ],
          ),
        );
      },
    );
  }
}
