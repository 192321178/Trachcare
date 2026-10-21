import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/Api/API_funcation/VideoApi.dart';
import 'package:trachcare/Screens/Views/patient/Bottomnavigationscreens/VideoPlayer_screen.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/components/video_card.dart';
import 'package:trachcare/style/design_system.dart';

/// WatchZone tab — the patient's therapy video library.
class Videospage extends StatefulWidget {
  const Videospage({super.key});

  @override
  State<Videospage> createState() => _VideospageState();
}

class _VideospageState extends State<Videospage> {
  Future<dynamic> _videos = Video().Fetchvideo();

  Future<void> _onRefresh() async {
    setState(() => _videos = Video().Fetchvideo());
    await _videos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.teal,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: TcPageHeader(
                  title: 'Therapy videos',
                  subtitle: 'Guided tracheostomy exercises',
                  child: _VideoHintBar(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.page,
                    AppSpacing.xl, AppSpacing.page, AppSpacing.xxxl),
                sliver: FutureBuilder(
                  future: _videos,
                  builder: (context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Column(
                          children: [
                            TcSkeleton(height: 226, radius: 20),
                            SizedBox(height: AppSpacing.lg),
                            TcSkeleton(height: 226, radius: 20),
                          ],
                        ),
                      );
                    }
                    final data = snapshot.data is List
                        ? snapshot.data as List
                        : const [];
                    if (data.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: TcEmptyState(
                          icon: Icons.videocam_off_rounded,
                          title: 'No videos yet',
                          message: snapshot.hasError
                              ? 'We could not reach the exercise library. Pull down to retry.'
                              : 'Your care team has not published any exercises yet.',
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: TcVideoCard(
                            video: data[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => video_player(
                                  Videoulrl:
                                      data[index]?['Video_url']?.toString() ??
                                          '',
                                  description:
                                      data[index]?['description']?.toString() ??
                                          '',
                                  title: data[index]?['title']?.toString() ??
                                      'Untitled session',
                                ),
                              ),
                            ),
                          ),
                        ),
                        childCount: data.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoHintBar extends StatelessWidget {
  const _VideoHintBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Watch a session, then tap it to mark it done',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
