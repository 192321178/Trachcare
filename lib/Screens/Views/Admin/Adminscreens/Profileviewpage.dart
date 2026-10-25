import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/json_client.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

import 'editprofile.dart';

/// The signed-in administrator's own record, read-only.
class a_ProfilePage extends StatefulWidget {
  const a_ProfilePage({super.key});

  @override
  State<a_ProfilePage> createState() => _a_ProfilePageState();
}

class _a_ProfilePageState extends State<a_ProfilePage> {
  late Future<dynamic> _admin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<dynamic> _load() {
    return _admin = fetchJson('$admindetailsUrl?doctor_id=$Doctor_id')
        .then((raw) => raw is Map ? raw['doctorInfo'] : raw);
  }

  Future<void> _refresh() => _load();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppbar(
        Title: 'My profile',
        subtitle: 'The account behind this console',
        height: 92,
        onTap: () => Navigator.maybePop(context),
      ),
      body: FutureBuilder(
        future: _admin,
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
          final name = data['username']?.toString() ?? 'Administrator';
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
                  role: 'Clinic administrator',
                  idLabel: 'Account ID $Doctor_id',
                  gradient: const LinearGradient(
                    colors: [AppColors.violet, Color(0xFF9C82E4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  fallbackIcon: Icons.admin_panel_settings_rounded,
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
                        builder: (_) => AdminEditProfile(doctorId: Doctor_id),
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
              'Passwords are never displayed on screen. Set a new one from the '
              'edit screen if you need to change it.',
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
