import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/json_client.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

import 'package:trachcare/Screens/Views/Admin/Adminscreens/patientlist%20copy.dart';

import 'editdoctordetails.dart';

class Doctordetails extends StatefulWidget {
  final String Doctor_id;

  const Doctordetails({super.key, required this.Doctor_id});

  @override
  State<Doctordetails> createState() => _DoctordetailsState();
}

class _DoctordetailsState extends State<Doctordetails> {
  late Future<dynamic> _doctor;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<dynamic> _load() {
    return _doctor =
        fetchJson('$doctordetailsUrl?doctor_id=${widget.Doctor_id}')
            .then((raw) => raw is Map ? raw['doctorInfo'] : raw);
  }

  Future<void> _refresh() => _load();

  Future<void> _confirmDelete() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this doctor?'),
        content: const Text(
            'Their login stops working straight away. Patient records they '
            'created stay in the clinic.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await deleteJson('$doctordetailsUrl?doctor_id=${widget.Doctor_id}');
      messenger.showSnackBar(
          const SnackBar(content: Text('Doctor removed from the clinic')));
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not remove this doctor')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppbar(
        Title: 'Doctor profile',
        subtitle: 'Read-only clinic record',
        height: 92,
        onTap: () => Navigator.maybePop(context),
        actionbutton: TcIconButton(
          icon: Icons.delete_outline_rounded,
          color: Colors.white,
          onPressed: _confirmDelete,
        ),
      ),
      body: FutureBuilder(
        future: _doctor,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.page),
              child: Column(
                children: [
                  TcSkeleton(height: 190, radius: 20),
                  SizedBox(height: AppSpacing.xl),
                  TcSkeleton(height: 132, radius: 20),
                ],
              ),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return TcEmptyState(
              icon: Icons.person_off_rounded,
              title: 'This record is unavailable',
              message: 'The doctor may have been removed. Go back to the list.',
              action: TcButton(
                label: 'Try again',
                icon: Icons.refresh_rounded,
                expand: false,
                onPressed: _refresh,
              ),
            );
          }

          final data = snapshot.data;
          final name = data['username']?.toString() ?? 'Unnamed doctor';
          final regNo = data['doctor_reg_no']?.toString() ?? '';
          final email = data['email']?.toString() ?? '';
          final phone = data['phone_number']?.toString() ?? '';
          final avatar = trachcareAsset(data['image_path']?.toString());

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, AppSpacing.lg, AppSpacing.page, 40),
              children: [
                TcProfileHero(
                  name: name,
                  imagePath: avatar,
                  role: 'Registered practitioner',
                  idLabel: 'Doctor ID ${widget.Doctor_id}',
                  fallbackIcon: Icons.local_hospital_rounded,
                ),
                const SizedBox(height: AppSpacing.xl),
                TcDetailGroup(
                  title: 'Contact',
                  children: [
                    TcDetailRow(
                        label: 'Email',
                        icon: Icons.mail_outline_rounded,
                        value: email),
                    TcDetailRow(
                        label: 'Phone',
                        value: phone,
                        icon: Icons.call_outlined),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                TcDetailGroup(
                  title: 'Credentials',
                  children: [
                    TcDetailRow(
                        label: 'Registration no.',
                        value: regNo,
                        icon: Icons.badge_outlined),
                    TcDetailRow(label: 'Display name', value: name),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                TcButton(
                  label: 'Edit details',
                  icon: Icons.edit_rounded,
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                          builder: (_) =>
                              Editdoctordetails(doctorId: widget.Doctor_id),
                        ))
                        .then((_) => _refresh());
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TcButton(
                  label: 'Their patients',
                  icon: Icons.groups_rounded,
                  gradient: const LinearGradient(
                    colors: [AppColors.sky, Color(0xFF6BA8DB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => patientlist(doctor_id: widget.Doctor_id),
                    ));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
