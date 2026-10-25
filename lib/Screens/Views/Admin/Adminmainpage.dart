import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trachcare/Api/API_funcation/DashboardApi.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/Appbar.dart';
import 'package:trachcare/components/Navbardrawer.dart';
import 'package:trachcare/components/ui_kit.dart';

import 'Adminscreens/Profileviewpage.dart';
import 'Bottomnavigator/Adddoctor.dart';
import 'Bottomnavigator/Admindb.dart';
import 'Bottomnavigator/videolist.dart';

/// Admin shell. Owns the one profile request, the app bar, the drawer and the
/// tab bar so the three tabs below are plain bodies.
class Adminmainpage extends StatefulWidget {
  const Adminmainpage({super.key});

  @override
  State<Adminmainpage> createState() => _AdminmainpageState();
}

class _AdminmainpageState extends State<Adminmainpage> {
  late Future<dynamic> _profile = AdminDashBoardApi().FetchDetials();
  int _index = 0;
  bool _exporting = false;

  Future<void> _refreshProfile() async {
    setState(() => _profile = AdminDashBoardApi().FetchDetials());
    await _profile;
  }

  Future<void> _downloadCSV() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _exporting = true);
    try {
      final response = await http.get(Uri.parse(exporturl));
      if (response.statusCode != 200) {
        messenger.showSnackBar(const SnackBar(
            content: Text('Could not reach the export service')));
        return;
      }

      String? targetDir;
      try {
        if (!Platform.isAndroid && !Platform.isIOS) {
          targetDir = await FilePicker.platform.getDirectoryPath();
        }
      } catch (_) {}

      if (targetDir == null) {
        try {
          if (Platform.isAndroid) {
            final ext = await getExternalStorageDirectory();
            targetDir = ext?.path;
          }
        } catch (_) {}
        targetDir ??= (await getApplicationDocumentsDirectory()).path;
      }

      final stamp = DateTime.now().millisecondsSinceEpoch;
      var file = File('$targetDir/patient_details_$stamp.csv');
      for (var n = 1; await file.exists(); n++) {
        file = File('$targetDir/patient_details_${stamp}_$n.csv');
      }
      await file.writeAsBytes(response.bodyBytes);

      messenger.showSnackBar(
        SnackBar(
          content: Text('Saved to: ${file.path}'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => OpenFile.open(file.path),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _confirmExport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export patient records'),
        content: const Text(
            'Downloads every patient record as a CSV. Choose where to save it '
            'on the next step.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Export')),
        ],
      ),
    );
    if (confirmed == true) await _downloadCSV();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _profile,
      builder: (context, snapshot) {
        final data = snapshot.hasData ? snapshot.data : null;
        final name = data?['username']?.toString() ?? 'Administrator';
        final regNo = data?['doctor_reg_no']?.toString() ?? '';
        final avatar = trachcareAsset(data?['image_path']?.toString());

        return Scaffold(
          extendBody: true,
          appBar: Appbar(
            Name: name,
            height: 92,
            notification: false,
            export: _index == 0,
            onExportPressed: _exporting ? null : _confirmExport,
          ),
          drawer: drawer(
            Name: name,
            reg_no: regNo,
            imagepath: NetworkImage(avatar),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (_) => const a_ProfilePage(),
                  ))
                  .then((_) => _refreshProfile());
            },
          ),
          body: IndexedStack(
            index: _index,
            children: [
              Admindb(onExport: _confirmExport),
              const Adddoctor(),
              const Videolist(),
            ],
          ),
          bottomNavigationBar: TcNavBar(
            currentIndex: _index,
            onSelected: (i) => setState(() => _index = i),
            items: const [
              TcNavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'Overview',
              ),
              TcNavItem(
                icon: Icons.person_add_alt_outlined,
                activeIcon: Icons.person_add_alt_rounded,
                label: 'Add doctor',
              ),
              TcNavItem(
                icon: Icons.video_library_outlined,
                activeIcon: Icons.video_library_rounded,
                label: 'Videos',
              ),
            ],
          ),
        );
      },
    );
  }
}
