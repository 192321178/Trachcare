import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:trachcare/Api/API_funcation/DashboardApi.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/Screens/Views/patient/patientscreens/calender.dart';
import 'package:trachcare/Screens/Views/patient/patientscreens/dailyupdates.dart';
import 'package:trachcare/style/design_system.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  List<dynamic> _reports = [];
  Future<dynamic>? _details;

  @override
  void initState() {
    super.initState();
    _details = PatientDashBoardApi().FetchDetials();
    _fetchReports();
  }

  Future<List<dynamic>> fetchDailyReport(String doctorId) async {
    final uri = Uri.parse('$dailyreport?patient_id=$patient_id');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      }
      throw Exception('Failed to load reports: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error: $e');
      return [];
    }
  }

  Future<void> _fetchReports() async {
    _reports = await fetchDailyReport(patient_id);
    if (mounted) setState(() {});
  }

  void _open(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _details,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(AppSpacing.page),
              child: Column(
                children: [
                  TcSkeleton(height: 150, radius: 26),
                  SizedBox(height: AppSpacing.xl),
                  TcSkeleton(height: 150, radius: 20),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            body: TcEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Records unavailable',
              message: 'We could not reach the TrachCare server.',
              action: SizedBox(
                width: 180,
                child: TcButton(
                  label: 'Retry',
                  onPressed: () => setState(
                      () => _details = PatientDashBoardApi().FetchDetials()),
                ),
              ),
            ),
          );
        }

        final patientDetails = snapshot.data['Dashboard'];
        final name = patientDetails['username'].toString();
        final rawImage = patientDetails['image_path'].toString();
        final imagePath =
            rawImage.length >= 2 ? rawImage.substring(2) : rawImage;
        final submitted = _reports.isNotEmpty;

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await _fetchReports();
                setState(() => _details = PatientDashBoardApi().FetchDetials());
                await _details;
              },
              color: AppColors.teal,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 110),
                children: [
                  TcPageHeader(
                    title: 'Daily records',
                    subtitle: 'Track symptoms and review your history',
                    actions: [
                      if (submitted)
                        const TcBadge(
                          label: 'Today logged',
                          color: AppColors.tealDeep,
                          background: Colors.white,
                          icon: Icons.check_circle_rounded,
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.page),
                    child: Column(
                      children: [
                        _RecordCard(
                          icon: Icons.edit_note_rounded,
                          title: 'Update daily queries',
                          description: submitted
                              ? 'Already submitted today — view your entry in history.'
                              : 'Answer a few quick questions about your breathing and comfort.',
                          ctaLabel: submitted ? 'View history' : 'Start update',
                          accent: submitted ? AppColors.sky : AppColors.teal,
                          accentSoft: submitted
                              ? AppColors.skySoft
                              : AppColors.mintSoft,
                          onTap: () => submitted
                              ? _open(
                                  calender(name: name, imagePath: imagePath))
                              : _open(YourdailyReports(
                                  name: name, imagePath: imagePath)),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _RecordCard(
                          icon: Icons.calendar_month_rounded,
                          title: 'Report history',
                          description:
                              'Browse every daily report your care team has received.',
                          ctaLabel: 'Open calendar',
                          accent: AppColors.violet,
                          accentSoft: const Color(0xFFEEE8FB),
                          onTap: () =>
                              _open(calender(name: name, imagePath: imagePath)),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.amberSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.amber, size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'If you have trouble breathing, contact your care team before completing this form.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    color: AppColors.inkBody,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.accent,
    required this.accentSoft,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String ctaLabel;
  final Color accent;
  final Color accentSoft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TcCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent, size: 25),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child:
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
              Icon(Icons.chevron_right_rounded, color: accent),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.inkMuted, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TcBadge(
              label: ctaLabel,
              color: Colors.white,
              background: accent,
              icon: Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
