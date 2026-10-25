import 'package:flutter/material.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/motion.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

/// One person in a [TcRosterScreen] list.
class TcRosterEntry {
  const TcRosterEntry({
    required this.key,
    required this.title,
    this.id,
    this.imagePath,
    this.chip,
    this.chipColor = AppColors.teal,
    this.chipSoft = AppColors.mintSoft,
  });

  final String key;
  final String title;
  final String? id;
  final String? imagePath;
  final String? chip;
  final Color chipColor;
  final Color chipSoft;
}

/// Searchable roster of people — shared by the doctor, patient and admin lists.
class TcRosterScreen extends StatefulWidget {
  const TcRosterScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.load,
    required this.entries,
    required this.onEntryTap,
    this.searchHint = 'Search by name',
    this.emptyTitle = 'No one on the list',
    this.emptyMessage,
    this.fallbackIcon = Icons.person_rounded,
    this.headerChild,
    this.embedded = false,
    this.export = false,
    this.onExportPressed,
  });

  final String title;
  final String subtitle;
  final Future<dynamic> Function() load;
  final List<TcRosterEntry> Function(dynamic raw) entries;
  final void Function(TcRosterEntry entry) onEntryTap;
  final String searchHint;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData fallbackIcon;
  final Widget? headerChild;

  /// True when a parent shell already draws the app bar — the roster then
  /// renders only its search field and list.
  final bool embedded;
  final bool export;
  final VoidCallback? onExportPressed;

  @override
  State<TcRosterScreen> createState() => _TcRosterScreenState();
}

class _TcRosterScreenState extends State<TcRosterScreen> {
  late Future<dynamic> _future;
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = widget.load();
  }

  @override
  void didUpdateWidget(TcRosterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.load, widget.load)) {
      setState(() => _future = widget.load());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final next = widget.load();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.lg, AppSpacing.page, 0),
          child: Column(
            children: [
              if (widget.headerChild != null) ...[
                widget.headerChild!,
                const SizedBox(height: AppSpacing.lg),
              ],
              _SearchBox(
                controller: _controller,
                hint: widget.searchHint,
                onChanged: (value) => setState(() => _query = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _RosterSkeleton();
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return TcEmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load the list',
                  message: 'Check the connection and try again.',
                  action: TcButton(
                    label: 'Try again',
                    icon: Icons.refresh_rounded,
                    expand: false,
                    onPressed: _refresh,
                  ),
                );
              }

              final all = widget.entries(snapshot.data);
              final needle = _query.trim().toLowerCase();
              final matches = needle.isEmpty
                  ? all
                  : all
                      .where((e) =>
                          e.title.toLowerCase().contains(needle) ||
                          (e.id ?? '').toLowerCase().contains(needle))
                      .toList();

              return RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.teal,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page, AppSpacing.lg, AppSpacing.page, 40),
                  children: [
                    if (matches.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: TcEmptyState(
                          title: widget.emptyTitle,
                          message: widget.emptyMessage ??
                              'Try a different spelling, or pull down to refresh.',
                        ),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 4, bottom: AppSpacing.md),
                        child: Text(
                          '${matches.length} ${matches.length == 1 ? "record" : "records"}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      for (var i = 0; i < matches.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: TcReveal(
                            index: i,
                            child: _RosterTile(
                              entry: matches[i],
                              fallbackIcon: widget.fallbackIcon,
                              onTap: () => widget.onEntryTap(matches[i]),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: NormalAppbar(
        Title: widget.title,
        subtitle: widget.subtitle,
        height: 92,
        export: widget.export,
        onExportPressed: widget.onExportPressed,
        onTap: () => Navigator.maybePop(context),
      ),
      body: body,
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.field,
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const SizedBox(
              width: AppSpacing.lg + 4,
              child: Icon(Icons.search_rounded,
                  size: 20, color: AppColors.inkMuted)),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                hintText: hint,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: AppColors.inkMuted),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _RosterTile extends StatelessWidget {
  const _RosterTile({
    required this.entry,
    required this.fallbackIcon,
    required this.onTap,
  });

  final TcRosterEntry entry;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TcCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          TcAvatar(
            imageUrl: entry.imagePath,
            fallbackIcon: fallbackIcon,
            size: 48,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (entry.id != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    entry.id!,
                    maxLines: 1,
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
          const SizedBox(width: AppSpacing.sm),
          if (entry.chip != null)
            TcBadge(
              label: entry.chip!,
              color: entry.chipColor,
              background: entry.chipSoft,
            )
          else
            const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
        ],
      ),
    );
  }
}

class _RosterSkeleton extends StatelessWidget {
  const _RosterSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: const [
        _SkeletonRow(),
        SizedBox(height: AppSpacing.md),
        _SkeletonRow(),
        SizedBox(height: AppSpacing.md),
        _SkeletonRow(),
        SizedBox(height: AppSpacing.md),
        _SkeletonRow(),
      ],
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const TcCard(
      padding: EdgeInsets.all(AppSpacing.md),
      shadows: [],
      child: Row(
        children: [
          TcSkeleton(height: 48, width: 48, radius: 24),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TcSkeleton(height: 14, width: 150),
                SizedBox(height: 8),
                TcSkeleton(height: 11, width: 90),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
