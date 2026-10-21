import 'package:flutter/material.dart';
import 'package:trachcare/Api/API_funcation/VideoApi.dart';
import 'package:trachcare/components/video_card.dart';
import 'package:trachcare/style/design_system.dart';

import 'VideoPlayer_screen.dart';

/// Body of the Admin "Videos" tab — previews the published library so the
/// administrator can check what patients are seeing.
class Videolist extends StatelessWidget {
  const Videolist({super.key});

  @override
  Widget build(BuildContext context) {
    return TcVideoLibrary(
      badgeLabel: 'Published',
      badgeColor: AppColors.violet,
      emptyMessage: 'Upload a lesson from the console to fill this library.',
      load: () async => (await Video().Fetchvideo()) ?? const [],
      onVideoTap: (video) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => a_videoplayer(
            Videoulrl: video?['Video_url']?.toString() ?? '',
            description: video?['description']?.toString() ?? '',
            title: video?['title']?.toString() ?? '',
          ),
        ));
      },
    );
  }
}
