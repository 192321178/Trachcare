import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/json_client.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

import 'editprofile.dart';

/// The signed-in doctor's own record. Read-only — editing happens in
/// [doctoreditprofile], which re-fetches the same row.
class d_ProfilePage extends StatefulWidget {
  const d_ProfilePage({super.key});

  @override
  State<d_ProfilePage> createState() => _d_ProfilePageState();
}

class _d_ProfilePageState extends State<d_ProfilePage> {
  late Future<dynamic> _doctor;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<dynamic> _load() {
    return _doctor = fetchJson('$doctordetailsUrl?doctor_id=$Doctor_id')
        .then((raw) => raw is Map ? raw['doctorInfo'] : raw);
  }

  Future<void> _refresh() => _load();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppbar(
        Title: 'My profile',
        subtitle: 'Details your clinic shows to patients',
        height: 92,
        onTap: () => Navigator.maybePop(context),
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
              icon: Icons.cloud_off_rounded,
              title: 'Could not load your profile',
              message: 'Check the connection and try again.',
              action: TcButton(
                label: 'Try again',
                icon: Icons.refresh_rounded,
                expand: false,
                onPressed: _refresh,
              ),
            );
          }

          final data = snapshot.data;
          final name = data['username']?.toString() ?? 'Doctor';
          final regNo = data['doctor_reg_no']?.toString() ?? '';
          final email = data['email']?.toString() ?? '';
          final phone = data['phone_number']?.toString() ?? '';

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, AppSpacing.lg, AppSpacing.page, 40),
              children: [
                TcProfileHero(
                  name: name,
                  imagePath: trachcareAsset(data['image_path']?.toString()),
                  role: 'Registered practitioner',
                  idLabel: 'Doctor ID $Doctor_id',
                  fallbackIcon: Icons.local_hospital_rounded,
                ),
                const SizedBox(height: AppSpacing.xl),
                TcDetailGroup(
                  title: 'Contact',
                  children: [
                    TcDetailRow(
                        label: 'Email',
                        value: email,
                        icon: Icons.mail_outline_rounded),
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
                    TcDetailRow(
                        label: 'Display name',
                        value: name,
                        icon: Icons.person_outline_rounded),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                const _PasswordNote(),
                const SizedBox(height: AppSpacing.xl),
                TcButton(
                  label: 'Edit details',
                  icon: Icons.edit_rounded,
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(
                        builder: (_) => doctoreditprofile(doctorId: Doctor_id),
                      ))
                      .then((_) => _refresh()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Explains why the account password is not echoed on screen.
class _PasswordNote extends StatelessWidget {
  const _PasswordNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.skySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: 20, color: AppColors.sky),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Your password is never shown here. Set a new one from the edit '
              'screen if you need to change it.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.tealDeep),
            ),
          ),
        ],
      ),
    );
  }
}
