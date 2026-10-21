import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/VideoApi.dart';
import 'package:trachcare/Api/API_funcation/json_client.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/components/video_card.dart';
import 'package:trachcare/style/design_system.dart';

import '../doctorscreens/VideoPlayer_screen.dart';
import '../doctorscreens/dailyupdatedetails.dart';
import 'Addpatients.dart';
import 'package:trachcare/style/responsive.dart';

/// Doctor home tab: today's chart activity plus a peek at the exercise library.
class DoctorDashBoard extends StatefulWidget {
  const DoctorDashBoard({super.key, this.onOpenTab});

  /// Switches the shell's bottom tab (1 = videos, 2 = patients).
  final void Function(int index)? onOpenTab;

  @override
  State<DoctorDashBoard> createState() => _DoctorDashBoardState();
}

class _DoctorDashBoardState extends State<DoctorDashBoard> {
  late Future<dynamic> _reports = _loadReports();
  late Future<List<dynamic>> _videos = _loadVideos();

  Future<dynamic> _loadReports() =>
      fetchJson('$viewstory?doctor_id=$Doctor_id');

  Future<List<dynamic>> _loadVideos() async =>
      (await Video().Fetchvideo()) ?? const [];

  Future<void> _refresh() async {
    final reports = _loadReports();
    final videos = _loadVideos();
    setState(() {
      _reports = reports;
      _videos = videos;
    });
    await Future.wait([reports, videos]);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.teal,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
            AppSpacing.page, AppSpacing.lg, AppSpacing.page, AppSize.s(120)),
        children: [
          TcSectionHeader(
            eyebrow: 'Today',
            title: 'Patient updates',
            subtitle:
                'Charts your patients refreshed in the last report window',
          ),
          const SizedBox(height: AppSpacing.sm),
          _UpdatesStrip(reports: _reports),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _Shortcut(
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Add patient',
                  subtitle: 'Start a new trach chart',
                  color: AppColors.teal,
                  soft: AppColors.mintSoft,
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const Addpatients())),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Shortcut(
                  icon: Icons.groups_rounded,
                  title: 'My patients',
                  subtitle: 'Search every chart',
                  color: AppColors.sky,
                  soft: AppColors.skySoft,
                  onTap: () => widget.onOpenTab?.call(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          TcSectionHeader(
            title: 'Therapy videos',
            subtitle: 'Prescribe a session from a patient chart',
            trailing: TextButton(
              onPressed: () => widget.onOpenTab?.call(1),
              child: const Text('See all'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder(
            future: _videos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  children: [
                    TcSkeleton(
                        height: AppSize.s(250),
                        width: AppSize.s(250),
                        radius: AppSize.s(20)),
                    SizedBox(width: AppSpacing.md),
                    TcSkeleton(
                        height: AppSize.s(250),
                        width: AppSize.s(200),
                        radius: AppSize.s(20)),
                  ],
                );
              }
              final data = snapshot.data;
              if (data == null || data.isEmpty) {
                return TcCard(
                  shadows: const [],
                  border: Border.all(color: AppColors.outline),
                  child: Row(
                    children: [
                      Icon(Icons.videocam_off_rounded,
                          color: AppColors.inkMuted, size: AppSize.s(22)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'No exercises published yet.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }
              // A scrollable Row sizes to its tallest card, so a two-line
              // title plus a two-line description cannot overflow a fixed box.
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final video in data.take(4))
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: SizedBox(
                          width: AppSize.s(250),
                          child: TcVideoCard(
                            video: video,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => videoplayer(
                                  Videoulrl:
                                      video?['Video_url']?.toString() ?? '',
                                  description:
                                      video?['description']?.toString() ?? '',
                                  title: video?['title']?.toString() ??
                                      'Untitled session',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UpdatesStrip extends StatelessWidget {
  const _UpdatesStrip({required this.reports});

  final Future<dynamic> reports;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: reports,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: AppSize.s(104),
            child: Row(
              children: [
                TcSkeleton(
                    height: AppSize.s(96),
                    width: AppSize.s(96),
                    radius: AppSize.s(20)),
                SizedBox(width: AppSpacing.md),
                TcSkeleton(
                    height: AppSize.s(96),
                    width: AppSize.s(96),
                    radius: AppSize.s(20)),
                SizedBox(width: AppSpacing.md),
                TcSkeleton(
                    height: AppSize.s(96),
                    width: AppSize.s(96),
                    radius: AppSize.s(20)),
              ],
            ),
          );
        }
        final data = rowsOf(snapshot.data);
        if (data.isEmpty) {
          return TcCard(
            shadows: const [],
            border: Border.all(color: AppColors.outline),
            child: Row(
              children: [
                Container(
                  width: AppSize.s(38),
                  height: AppSize.s(38),
                  decoration: BoxDecoration(
                    color: AppColors.mintSoft,
                    borderRadius: BorderRadius.circular(AppSize.s(12)),
                  ),
                  child: Icon(Icons.check_rounded,
                      color: AppColors.teal, size: AppSize.s(20)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'No patient has filed an update today.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox(
          height: AppSize.s(104),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final update = data[index];
              return _UpdateBubble(update: update);
            },
          ),
        );
      },
    );
  }
}

class _UpdateBubble extends StatelessWidget {
  const _UpdateBubble({required this.update});

  final dynamic update;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSize.s(78),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSize.s(16)),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => Viewdailyupdates(
            // The backend matches on a full YYYY-MM-DD; trimming the century
            // here made every day report come back empty.
            selecteddate: update['date'].toString().split(' ').first,
            patientId: update['patient_id'],
            imagePath: update['image_path'].toString(),
            name: update['username'],
          ),
        )),
        child: Column(
          children: [
            TcAvatar(
              imageUrl: trachcareAsset(update['image_path']?.toString()),
              size: AppSize.s(62),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              update['username']?.toString() ?? 'Patient',
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.soft,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color soft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TcCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSize.s(42),
            height: AppSize.s(42),
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(AppSize.s(13)),
            ),
            child: Icon(icon, color: color, size: AppSize.s(21)),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 2,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}
