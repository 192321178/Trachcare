import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/Screens/Views/patient/patientscreens/editprofile.dart';
import 'package:trachcare/style/design_system.dart';

class p_ProfilePage extends StatefulWidget {
  const p_ProfilePage({super.key});

  @override
  State<p_ProfilePage> createState() => _p_ProfilePageState();
}

class _p_ProfilePageState extends State<p_ProfilePage> {
  late Future<dynamic> _details = _fetch();

  Future<dynamic> _fetch() async {
    try {
      final response = await http.post(
        Uri.parse(getpatientdetialsurl),
        body: jsonEncode({'patient_id': patient_id.toString()}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['pateintinfo'];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
          future: _details,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _ProfileSkeleton();
            }
            if (!snapshot.hasData) {
              return TcEmptyState(
                icon: Icons.person_off_rounded,
                title: 'Profile unavailable',
                message: 'We could not load your details.',
                action: SizedBox(
                  width: 170,
                  child: TcButton(
                    label: 'Retry',
                    onPressed: () => setState(() => _details = _fetch()),
                  ),
                ),
              );
            }

            final data = snapshot.data;
            final rawImage = data['image_path'].toString();
            final imagepath =
                rawImage.length >= 2 ? rawImage.substring(2) : rawImage;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 132,
                  backgroundColor: AppColors.teal,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: TcIconButton(
                      icon: Icons.arrow_back_rounded,
                      color: Colors.white,
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  title: const Text('My profile',
                      style: TextStyle(color: Colors.white)),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(30)),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -46),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.page),
                      child: Column(
                        children: [
                          TcAvatar(
                            imageUrl: trachcareAsset('$imagepath'),
                            size: 92,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            data['username'].toString(),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          TcBadge(
                            label: 'Patient · ID ${data['doctor_reg_no']}',
                            color: AppColors.teal,
                            background: AppColors.mintSoft,
                            icon: Icons.verified_user_rounded,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          TcCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: AppSpacing.md),
                            child: Column(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text('Contact details',
                                      style: AppType.eyebrow),
                                ),
                                TcDetailRow(
                                  label: 'Email',
                                  value: data['email'].toString(),
                                  icon: Icons.mail_outline_rounded,
                                ),
                                const Divider(),
                                TcDetailRow(
                                  label: 'Phone',
                                  value: data['phone_number'].toString(),
                                  icon: Icons.call_outlined,
                                ),
                                const Divider(),
                                TcDetailRow(
                                  label: 'Assigned doctor',
                                  value: data['doctor_reg_no'].toString(),
                                  icon: Icons.local_hospital_outlined,
                                ),
                                const Divider(),
                                TcDetailRow(
                                  label: 'Password',
                                  value: '••••••••',
                                  icon: Icons.lock_outline_rounded,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          TcButton(
                            label: 'Edit profile',
                            icon: Icons.edit_rounded,
                            onPressed: () =>
                                Navigator.of(context)
                                    .push(CupertinoPageRoute(
                              builder: (context) => Editpatientprofile(
                                patientId: patient_id,
                                imagepath: imagepath,
                                doctorRegNo: data['doctor_reg_no'].toString(),
                                username: data['username'].toString(),
                                email: data['email'].toString(),
                                phoneNumber: data['phone_number'].toString(),
                                password: data['password'].toString(),
                              ),
                            ))
                                    .then((_) {
                              // Edits come back here, so refresh the card.
                              if (mounted) {
                                setState(() => _details = _fetch());
                              }
                            }),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: const [
        TcSkeleton(height: 120, radius: 26),
        SizedBox(height: AppSpacing.xxxl),
        Center(child: TcSkeleton(height: 92, width: 92, radius: 46)),
        SizedBox(height: AppSpacing.lg),
        Center(child: TcSkeleton(height: 22, width: 160)),
        SizedBox(height: AppSpacing.xl),
        TcSkeleton(height: 210, radius: 20),
      ],
    );
  }
}
