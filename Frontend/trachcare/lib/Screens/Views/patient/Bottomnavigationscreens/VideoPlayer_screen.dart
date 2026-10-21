import 'package:flutter/material.dart';
import 'package:trachcare/components/video_card.dart';

/// Patient-facing therapy video player.
class video_player extends StatelessWidget {
  final String Videoulrl;
  final String title;
  final String description;

  const video_player({
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
    );
  }
}
