import 'package:flutter/material.dart';
import 'package:trachcare/components/video_card.dart';

/// Admin preview of a published therapy video.
class a_videoplayer extends StatelessWidget {
  final String Videoulrl;
  final String title;
  final String description;

  const a_videoplayer({
    super.key,
    required this.Videoulrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return TcVideoPlayerScaffold(
      relativeUrl: Videoulrl,
      title: title,
      description: description,
      eyebrow: 'Preview',
      note: 'This is what patients see in their WatchZone tab.',
    );
  }
}
