import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/motion.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

class DoctorApprovalsScreen extends StatefulWidget {
  const DoctorApprovalsScreen({super.key});

  @override
  State<DoctorApprovalsScreen> createState() => _DoctorApprovalsScreenState();
}

class _DoctorApprovalsScreenState extends State<DoctorApprovalsScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _doctors = [];

  /// Doctor ids with a decision request in flight — buttons stay disabled
  /// until the server answers so an approve can't be sent twice.
  final Set<String> _acting = {};

  @override
  void initState() {
    super.initState();
    _fetchPendingDoctors();
  }

  Future<void> _fetchPendingDoctors() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await http.get(Uri.parse(PendingDoctorsUrl));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['Status'] == true) {
          setState(() {
            _doctors = data['data'] ?? [];
            _loading = false;
          });
          return;
        }
      }
      setState(() {
        _loading = false;
        _error = 'Failed to load pending doctors.';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Could not connect to server.';
      });
    }
  }

  Future<void> _handleDecision({required String doctorId, required bool approve}) async {
    if (_acting.contains(doctorId)) return;
    setState(() => _acting.add(doctorId));
    final endpoint = approve ? ApproveDoctorUrl : RejectDoctorUrl;
    try {
      final res = await http.post(
        Uri.parse(endpoint),
        body: jsonEncode({
          'id': doctorId,
          'rejection_reason': 'Rejected by Administrator review.',
        }),
      );

      final data = jsonDecode(res.body);
      if (data['Status'] == true) {
        toastification.show(
          type: approve ? ToastificationType.success : ToastificationType.warning,
          style: ToastificationStyle.flatColored,
          context: context,
          title: Text(data['message'] ?? (approve ? 'Doctor approved' : 'Doctor rejected')),
          icon: Icon(
            approve ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: approve ? Colors.green : Colors.orange,
          ),
          showIcon: true,
          showProgressBar: false,
          autoCloseDuration: const Duration(seconds: 3),
        );
        _fetchPendingDoctors();
      } else {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          context: context,
          title: Text(data['message'] ?? 'Action failed'),
          icon: const Icon(Icons.error_outline, color: Colors.red),
          showIcon: true,
          showProgressBar: false,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        context: context,
        title: const Text('Server connection failed'),
        icon: const Icon(Icons.error_outline, color: Colors.red),
        showIcon: true,
        showProgressBar: false,
        autoCloseDuration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) setState(() => _acting.remove(doctorId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Doctor Approvals',
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSize.s(18),
            fontWeight: FontWeight.w700,
            color: AppColors.inkDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.inkDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const _ApprovalsSkeleton()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: GoogleFonts.plusJakartaSans(color: AppColors.danger)),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _fetchPendingDoctors,
                        style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _doctors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: AppSize.s(54), color: AppColors.tealSoft),
                          const SizedBox(height: 14),
                          Text(
                            'All caught up!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: AppSize.s(18),
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'No pending doctor registrations to review.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: AppSize.s(13),
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchPendingDoctors,
                      color: AppColors.teal,
                      child: ListView.separated(
                        padding: EdgeInsets.all(AppSpacing.page),
                        itemCount: _doctors.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final doc = _doctors[index];
                          final id = doc['id']?.toString() ?? '';
                          final username = doc['username']?.toString() ?? 'Doctor';
                          final email = doc['email']?.toString() ?? '';
                          final phone = doc['phone_number']?.toString() ?? '';
                          final regDate = doc['created_at']?.toString() ?? '';
                          final acting = _acting.contains(id);

                          return TcReveal(
                            index: index,
                            child: TcCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: AppSize.s(44),
                                      height: AppSize.s(44),
                                      decoration: BoxDecoration(
                                        color: AppColors.mintSoft,
                                        borderRadius: AppRadius.thumb,
                                      ),
                                      child: const Icon(
                                        Icons.medical_services_outlined,
                                        color: AppColors.teal,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            username,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: AppSize.s(16),
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.inkDark,
                                            ),
                                          ),
                                          Text(
                                            email,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: AppSize.s(12.5),
                                              color: AppColors.inkMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.amberSoft,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'PENDING',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: AppSize.s(10),
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 22),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined,
                                        size: 15, color: AppColors.inkMuted),
                                    const SizedBox(width: 6),
                                    Text(
                                      phone,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: AppSize.s(12),
                                        color: AppColors.inkBody,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 14, color: AppColors.inkMuted),
                                    const SizedBox(width: 6),
                                    Text(
                                      regDate.split(' ').first,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: AppSize.s(11.5),
                                        color: AppColors.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: acting
                                            ? null
                                            : () => _handleDecision(
                                                doctorId: id, approve: false),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.danger,
                                          side: const BorderSide(color: AppColors.danger),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(AppSize.s(10)),
                                          ),
                                        ),
                                        child: const Text('REJECT'),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: acting
                                            ? null
                                            : () => _handleDecision(
                                                doctorId: id, approve: true),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.teal,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(AppSize.s(10)),
                                          ),
                                        ),
                                        child: const Text('APPROVE'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _ApprovalsSkeleton extends StatelessWidget {
  const _ApprovalsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => const TcCard(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TcSkeleton(height: 44, width: 44, radius: 10),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TcSkeleton(height: 14, width: 150),
                      SizedBox(height: 8),
                      TcSkeleton(height: 11, width: 200),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            TcSkeleton(height: 12, width: 240),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: TcSkeleton(height: 40, radius: 10)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: TcSkeleton(height: 40, radius: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
