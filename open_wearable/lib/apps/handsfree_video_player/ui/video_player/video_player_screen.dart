import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_wearable/apps/handsfree_video_player/data/repositories/gesture_tracker.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final GestureTracker gestureTracker;
  const VideoPlayerScreen({
    super.key,
    required this.url,
    required this.gestureTracker,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  static final yawLeftMessage = "Skipped ${skipDuration}s backwards";
  static final yawRightMessage = "Skipped ${skipDuration}s forward";
  static final pitchUpMessage = "Toggled paused state";
  static final skipDuration = 30;
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final videoId = YoutubePlayer.convertUrlToId(widget.url) ?? "";
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(enableCaption: false),
    );

    widget.gestureTracker.listen((gesture) {
      switch (gesture) {
        case Gesture.yawLeft:
          final position = _youtubeController.value.position;
          _youtubeController.seekTo(
            Duration(seconds: position.inSeconds - skipDuration),
          );

          _showToast(context, yawLeftMessage);
          break;
        case Gesture.yawRight:
          final position = _youtubeController.value.position;
          _youtubeController.seekTo(
            Duration(seconds: position.inSeconds + skipDuration),
          );

          _showToast(context, yawRightMessage);
          break;
        case Gesture.pitchUp:
          final isPlaying = _youtubeController.value.isPlaying;
          isPlaying ? _youtubeController.pause() : _youtubeController.play();

          _showToast(context, pitchUpMessage);
          break;
      }
    });
  }

  void _showToast(BuildContext context, String toast) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: IntrinsicWidth(
            child: Center(
              child: Text(
                toast,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          elevation: 2,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: Center(
        child: YoutubePlayer(
          controller: _youtubeController,
          showVideoProgressIndicator: true,
          topActions: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.gestureTracker.close();
    _youtubeController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }
}
