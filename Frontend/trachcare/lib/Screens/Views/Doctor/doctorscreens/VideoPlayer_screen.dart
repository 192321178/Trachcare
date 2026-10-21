import 'package:flutter/material.dart';
import 'package:trachcare/components/video_card.dart';

/// Doctor preview of a published therapy video.
class videoplayer extends StatelessWidget {
  final String Videoulrl;
  final String title;
  final String description;

  const videoplayer({
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
      note: 'Assign this session from a patient record if it suits their plan.',
    );
  }
}
