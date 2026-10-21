import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

/// Therapy-video thumbnail card shared by the patient, doctor and admin
/// libraries. Accepts the raw row from `addvideos.php` so callers do not have
/// to agree on which fields exist.
class TcVideoCard extends StatelessWidget {
  const TcVideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.badgeLabel = 'Exercise',
    this.badgeColor = AppColors.teal,
  });

  final dynamic video;
  final VoidCallback? onTap;
  final String badgeLabel;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    final title = video?['title']?.toString() ?? 'Untitled session';
    final description = video?['description']?.toString() ?? '';

    return TcCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 158,
                width: double.infinity,
                color: AppColors.surfaceAlt,
                child: Image.network(
                  trachcareAsset(video?['Thumbnail_url']?.toString()),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image_rounded,
                        color: AppColors.inkMuted),
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0x6B000000), Color(0x00000000)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.raised,
                      ),
                      child: Icon(Icons.play_arrow_rounded,
                          color: badgeColor, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: TcBadge(
                        label: badgeLabel,
                        color: Colors.white,
                        background: Color(0x59000000),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.inkMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark theatre-style player used by all three roles. Owns the media_kit
/// [Player] and disposes it with the route.
class TcVideoPlayerScaffold extends StatefulWidget {
  const TcVideoPlayerScaffold({
    super.key,
    required this.relativeUrl,
    required this.title,
    required this.description,
    this.eyebrow = 'Now playing',
    this.note =
        'Take your time — repeat the movement slowly rather than rushing.',
  });

  final String relativeUrl;
  final String title;
  final String description;
  final String eyebrow;
  final String note;

  @override
  State<TcVideoPlayerScaffold> createState() => _TcVideoPlayerScaffoldState();
}

class _TcVideoPlayerScaffoldState extends State<TcVideoPlayerScaffold> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.open(Media(trachcareAsset(widget.relativeUrl)));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071A17),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.md,
                  AppSpacing.page, AppSpacing.md),
              child: Row(
                children: [
                  TcIconButton(
                    icon: Icons.arrow_back_rounded,
                    color: Colors.white,
                    background: Colors.white.withValues(alpha: 0.14),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.eyebrow.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppColors.mint,
                          ),
                        ),
                        const Text(
                          'TrachCare therapy',
                          style:
                              TextStyle(fontSize: 12.5, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black,
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).width * 9 / 16,
                child: Video(controller: controller),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.lg),
                      TcCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppColors.mintSoft,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Icon(Icons.notes_rounded,
                                      size: 18, color: AppColors.teal),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text('What to focus on',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              widget.description.isEmpty
                                  ? 'Follow along at a comfortable pace and stop if you feel breathless.'
                                  : widget.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.mint, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_rounded,
                                color: AppColors.teal, size: 22),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                widget.note,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: AppColors.tealDeep,
                                        fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vertical list of [TcVideoCard]s with loading, empty and pull-to-refresh
/// states already handled.
class TcVideoLibrary extends StatefulWidget {
  const TcVideoLibrary({
    super.key,
    required this.load,
    required this.onVideoTap,
    this.emptyTitle = 'No videos yet',
    this.emptyMessage =
        'Nothing has been published to the therapy library yet.',
    this.badgeLabel = 'Exercise',
    this.badgeColor = AppColors.teal,
    this.padding = const EdgeInsets.fromLTRB(
        AppSpacing.page, AppSpacing.lg, AppSpacing.page, 40),
  });

  final Future<dynamic> Function() load;
  final void Function(dynamic video) onVideoTap;
  final String emptyTitle;
  final String emptyMessage;
  final String badgeLabel;
  final Color badgeColor;
  final EdgeInsets padding;

  @override
  State<TcVideoLibrary> createState() => _TcVideoLibraryState();
}

class _TcVideoLibraryState extends State<TcVideoLibrary> {
  late Future<dynamic> _future = widget.load();

  @override
  void didUpdateWidget(TcVideoLibrary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.load, widget.load)) {
      _future = widget.load();
    }
  }

  Future<void> _refresh() async {
    setState(() => _future = widget.load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.teal,
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              padding: widget.padding,
              children: const [
                TcSkeleton(height: 226, radius: 20),
                SizedBox(height: AppSpacing.lg),
                TcSkeleton(height: 226, radius: 20),
                SizedBox(height: AppSpacing.lg),
                TcSkeleton(height: 226, radius: 20),
              ],
            );
          }

          final data = snapshot.data is List ? snapshot.data as List : const [];
          if (data.isEmpty) {
            return ListView(
              padding: widget.padding,
              children: [
                const SizedBox(height: 60),
                TcEmptyState(
                  icon: Icons.videocam_off_rounded,
                  title: widget.emptyTitle,
                  message: snapshot.hasError
                      ? 'We could not reach the library. Pull down to retry.'
                      : widget.emptyMessage,
                ),
              ],
            );
          }

          return ListView.builder(
            padding: widget.padding,
            itemCount: data.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: TcVideoCard(
                video: data[index],
                badgeLabel: widget.badgeLabel,
                badgeColor: widget.badgeColor,
                onTap: () => widget.onVideoTap(data[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
