import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_wearable/apps/handsfree_youtube_player/data/repositories/gesture_tracker.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// A screen that displays a YouTube video player with handsfree gesture controls.
///
/// This widget allows the user to play a YouTube video and control playback
/// (skip forward/backward, pause/play) using head gestures detected by [GestureTracker].
class VideoPlayerScreen extends StatefulWidget {
  /// The YouTube video URL to play.
  final String url;

  /// The gesture tracker used to listen for head gestures.
  final GestureTracker gestureTracker;

  /// Creates a [VideoPlayerScreen].
  const VideoPlayerScreen({
    super.key,
    required this.url,
    required this.gestureTracker,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

/// State for [VideoPlayerScreen], manages video playback and gesture handling.
class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  /// Message shown when skipping backwards.
  static final yawLeftMessage = "Skipped ${skipDuration}s backwards";

  /// Message shown when skipping forward.
  static final yawRightMessage = "Skipped ${skipDuration}s forward";

  /// Message shown when toggling pause/play.
  static final pitchUpMessage = "Toggled paused state";

  /// Number of seconds to skip.
  static final skipDuration = 30;

  /// Controller for the YouTube player.
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

  /// Shows a temporary toast message using a [SnackBar].
  ///
  /// [context] is the build context.
  /// [toast] is the message to display.
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
