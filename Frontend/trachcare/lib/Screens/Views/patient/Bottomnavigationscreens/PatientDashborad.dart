import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trachcare/Api/API_funcation/DashboardApi.dart';
import 'package:trachcare/Api/API_funcation/VideoApi.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/Appbar.dart';
import 'package:trachcare/components/Navbardrawer.dart';
import 'package:trachcare/components/Spigottingsheet.dart';
import 'package:trachcare/components/care_pulse.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/Screens/Views/patient/Bottomnavigationscreens/VideoPlayer_screen.dart';
import 'package:trachcare/Screens/Views/patient/patientscreens/patientprofile.dart';
import 'package:trachcare/Screens/Views/patient/patientscreens/reminders.dart';
import 'package:trachcare/services/reminder_service.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

class PatientDashBoard extends StatefulWidget {
  const PatientDashBoard({super.key});

  @override
  State<PatientDashBoard> createState() => _PatientDashBoardState();
}

class _PatientDashBoardState extends State<PatientDashBoard> {
  Future<dynamic>? _details;

  @override
  void initState() {
    super.initState();
    _details = PatientDashBoardApi().FetchDetials();
  }

  Future<void> _onRefresh() async {
    setState(() => _details = PatientDashBoardApi().FetchDetials());
    await _details;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _details,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _DashboardSkeleton();
        }
        if (!snapshot.hasData) {
          return Scaffold(
            body: TcEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Nothing to show yet',
              message: snapshot.hasError
                  ? 'We could not load your dashboard. Check your connection and retry.'
                  : 'Your care team has not shared any updates yet.',
              action: SizedBox(
                width: AppSize.s(180),
                child: TcButton(label: 'Try again', onPressed: _onRefresh),
              ),
            ),
          );
        }

        final patientDetails = snapshot.data['Dashboard'];
        final status = snapshot.data['status'];

        final pending = <String>[];
        final hour = DateTime.now().hour;
        for (final slot in _slots) {
          if (status[slot.key]?.toString() == '0' &&
              hour >= slot.from &&
              hour < slot.to) {
            pending.add(slot.short);
          }
        }

        final appointment = patientDetails['appoinment'].toString();
        final name = patientDetails['username'].toString();
        final registration = patientDetails['patient_id'].toString();
        final rawImage = patientDetails['image_path'].toString();
        final imagePath =
            rawImage.length >= 2 ? rawImage.substring(2) : rawImage;

        // The reminder engine lives on the phone, so it learns the name it
        // should open each message with from the record just fetched.
        if (name.trim().isNotEmpty) {
          ReminderService.instance.setPatientName(name);
        }

        return Scaffold(
          appBar: Appbar(
            Name: name,
            height: AppSize.s(78),
            notification: pending.isNotEmpty,
            notificationlists: pending,
            imagePath: trachcareAsset('$imagePath'),
          ),
          drawer: drawer(
            Name: name,
            reg_no: registration,
            imagepath: NetworkImage(trachcareAsset('$imagePath')),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => p_ProfilePage(),
              ));
            },
          ),
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.teal,
            child: ListView(
              padding:
                  EdgeInsets.only(top: AppSpacing.xl, bottom: AppSize.s(110)),
              children: [
                _SpigottingCard(status: status),
                const SizedBox(height: AppSpacing.lg),
                CarePulseCard(patientName: name),
                const SizedBox(height: AppSpacing.lg),
                _AppointmentCard(appointment: appointment),
                const SizedBox(height: AppSpacing.xxl),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  child: TcSectionHeader(
                    eyebrow: 'Daily plan',
                    title: 'Exercises for TrachCare',
                    subtitle: 'Short guided sessions from your care team',
                  ),
                ),
                const _ExerciseCarousel(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Slot {
  const _Slot(this.key, this.label, this.short, this.from, this.to);

  final String key;
  final String label;
  final String short;
  final int from;
  final int to;
}

const List<_Slot> _slots = [
  _Slot('status_10', '10 AM', '10 AM', 10, 12),
  _Slot('status_12', '12 PM', '12 PM', 12, 14),
  _Slot('status_2', '2 PM', '2 PM', 14, 16),
  _Slot('status_4', '4 PM', '4 PM', 16, 18),
  _Slot('status_6', '6 PM', '6 PM', 18, 20),
];

class _SpigottingCard extends StatelessWidget {
  const _SpigottingCard({required this.status});

  final dynamic status;

  void _openSheet(BuildContext context) {
    showCupertinoModalBottomSheet(
      isDismissible: true,
      enableDrag: true,
      expand: false,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => const SizedBox(
        width: double.infinity,
        child: Spigottingsheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = _slots.where((s) => status[s.key]?.toString() == '1').length;
    final hour = DateTime.now().hour;

    return TcCard(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Spigotting status', style: AppType.eyebrow),
                    SizedBox(height: AppSize.s(5)),
                    Text(
                      'How long can you breathe today?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              TcBadge(
                label: '$done/${_slots.length} done',
                color:
                    done == _slots.length ? AppColors.success : AppColors.teal,
                background: done == _slots.length
                    ? AppColors.successSoft
                    : AppColors.mintSoft,
                icon: Icons.timeline_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              for (final slot in _slots)
                Expanded(
                  child: _SessionDot(
                    slot: slot,
                    attended: status[slot.key]?.toString() == '1',
                    isNowWindow: hour >= slot.from && hour < slot.to,
                    onTap: () => _onTapSlot(context, slot),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSize.s(11)),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppSize.s(14)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: AppSize.s(16), color: AppColors.teal),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Tap an open session to log how long you managed.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.inkMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onTapSlot(BuildContext context, _Slot slot) {
    final attended = status[slot.key]?.toString() == '1';
    final hour = DateTime.now().hour;
    final open = !attended && hour >= slot.from && hour < slot.to;

    if (open) {
      _openSheet(context);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          attended ? Icons.check_circle_rounded : Icons.schedule_rounded,
          color: attended ? AppColors.success : AppColors.amber,
          size: AppSize.s(34),
        ),
        title: Text(attended ? 'Session complete' : 'Session unavailable'),
        content: Text(
          attended
              ? 'You already logged your ${slot.label} spigotting session.'
              : 'The ${slot.label} window is not open right now. It runs between ${slot.label} and ${slot.to == 20 ? '8 PM' : '${slot.to - 12 == 0 ? 12 : slot.to - 12} PM'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SessionDot extends StatelessWidget {
  const _SessionDot({
    required this.slot,
    required this.attended,
    required this.isNowWindow,
    required this.onTap,
  });

  final _Slot slot;
  final bool attended;
  final bool isNowWindow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = attended
        ? AppColors.successSoft
        : isNowWindow
            ? AppColors.amberSoft
            : AppColors.surfaceMuted;
    final fg = attended
        ? AppColors.success
        : isNowWindow
            ? AppColors.amber
            : AppColors.inkMuted;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: AppSize.s(44),
            height: AppSize.s(44),
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isNowWindow && !attended
                      ? AppColors.amber
                      : Colors.transparent,
                  width: AppSize.s(2)),
              boxShadow: isNowWindow && !attended ? AppShadows.glow : null,
            ),
            child: Icon(
              attended
                  ? Icons.check_rounded
                  : isNowWindow
                      ? Icons.schedule_rounded
                      : Icons.circle_outlined,
              size: AppSize.s(20),
              color: fg,
            ),
          ),
          SizedBox(height: AppSize.s(6)),
          Text(
            slot.short,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSize.s(10),
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final String appointment;

  @override
  Widget build(BuildContext context) {
    return TcCard(
      gradient: AppColors.mintGradient,
      shadows: null,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: AppSize.s(46),
            height: AppSize.s(46),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppShadows.card,
            ),
            child: Icon(Icons.event_available_rounded,
                color: AppColors.teal, size: AppSize.s(22)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next appointment',
                    style: AppType.eyebrow.copyWith(color: AppColors.tealDeep)),
                SizedBox(height: AppSize.s(4)),
                Text(
                  appointment.isEmpty ? 'Not scheduled yet' : appointment,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.tealDeep,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCarousel extends StatefulWidget {
  const _ExerciseCarousel();

  @override
  State<_ExerciseCarousel> createState() => _ExerciseCarouselState();
}

class _ExerciseCarouselState extends State<_ExerciseCarousel> {
  late final PageController _controller =
      PageController(viewportFraction: 0.78);
  Timer? _timer;
  Future<dynamic>? _videos;

  @override
  void initState() {
    super.initState();
    _videos = Video().Fetchvideo();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;
      final page = _controller.page ?? 0;
      _controller.animateToPage(
        (page + 1).clamp(0, 2).toInt(),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.s(236),
      child: FutureBuilder(
        future: _videos,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(strokeWidth: AppSize.s(2.4)));
          }
          final data = snapshot.data;
          if (data == null || data is! List || data.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: TcEmptyState(
                icon: Icons.play_disabled_rounded,
                title: 'No exercises yet',
                message: 'Your care team will add therapy videos here.',
              ),
            );
          }
          return PageView.builder(
            controller: _controller,
            itemCount: data.length < 3 ? data.length : 3,
            itemBuilder: (context, index) {
              final video = data[index];
              final thumb = video['Thumbnail_url']?.toString() ?? '';
              final path = thumb.length >= 2 ? thumb.substring(2) : thumb;

              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page, vertical: AppSpacing.sm),
                child: TcCard(
                  padding: EdgeInsets.zero,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => video_player(
                        Videoulrl: video['Video_url']?.toString() ?? '',
                        description: video['description']?.toString() ?? '',
                        title: video['title']?.toString() ?? '',
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              trachcareAsset('$path'),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const ColoredBox(
                                color: AppColors.surfaceAlt,
                                child: Icon(Icons.movie_filter_outlined,
                                    color: AppColors.inkMuted),
                              ),
                            ),
                            const Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                    gradient: AppColors.scrimGradient),
                              ),
                            ),
                            const Center(
                              child: _PlayGlyph(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                        child: Text(
                          video['title']?.toString() ?? 'Untitled',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PlayGlyph extends StatelessWidget {
  const _PlayGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.s(46),
      height: AppSize.s(46),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        shape: BoxShape.circle,
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.7), width: AppSize.s(1.6)),
      ),
      child: Icon(Icons.play_arrow_rounded,
          color: Colors.white, size: AppSize.s(26)),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        TcSkeleton(height: AppSize.s(190), radius: AppSize.s(20)),
        SizedBox(height: AppSpacing.lg),
        TcSkeleton(height: AppSize.s(84), radius: AppSize.s(20)),
        SizedBox(height: AppSpacing.xxl),
        TcSkeleton(height: AppSize.s(20), width: AppSize.s(180)),
        SizedBox(height: AppSpacing.lg),
        TcSkeleton(height: AppSize.s(220), radius: AppSize.s(20)),
      ],
    );
  }
}
