import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/VideoApi.dart';
import 'package:trachcare/components/video_card.dart';
import 'package:trachcare/style/design_system.dart';

import 'VideoPlayer_screen.dart';

/// The exercise library the doctor can prescribe from. Body only — the doctor
/// shell supplies the app bar.
class Videolist extends StatelessWidget {
  const Videolist({super.key});

  @override
  Widget build(BuildContext context) {
    return TcVideoLibrary(
      badgeLabel: 'Exercise library',
      badgeColor: AppColors.violet,
      emptyMessage: 'The admin team has not published any therapy videos yet.',
      load: () async => (await Video().Fetchvideo()) ?? const [],
      onVideoTap: (video) => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => videoplayer(
          Videoulrl: video?['Video_url']?.toString() ?? '',
          description: video?['description']?.toString() ?? '',
          title: video?['title']?.toString() ?? 'Untitled session',
        ),
      )),
    );
  }
}
