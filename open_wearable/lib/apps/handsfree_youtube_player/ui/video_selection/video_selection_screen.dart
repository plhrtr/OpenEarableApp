import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/handsfree_youtube_player/data/repositories/gesture_tracker.dart';
import 'package:open_wearable/apps/handsfree_youtube_player/data/services/gyroscope_service.dart';
import 'package:open_wearable/apps/handsfree_youtube_player/ui/tutorial/tutorial_screen.dart';
import 'package:open_wearable/apps/handsfree_youtube_player/ui/video_player/video_player_screen.dart';
import 'package:provider/provider.dart';

/// The main screen for selecting a YouTube video.
///
/// Allows the user to enter a YouTube video URL and navigate to the video player.
/// Also provides access to the tutorial screen.
class VideoSelectionScreen extends StatefulWidget {
  /// Creates a [VideoSelectionScreen].
  const VideoSelectionScreen({super.key});

  @override
  State<VideoSelectionScreen> createState() => _VideoSelectionScreenState();
}

/// State for [VideoSelectionScreen], manages URL input and navigation.
class _VideoSelectionScreenState extends State<VideoSelectionScreen> {
  /// Controller for the YouTube URL input field.
  final TextEditingController _urlController = TextEditingController();

  /// Error message to display if the URL is invalid or empty.
  String? _errorText;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Handles the Play button press.
  void _playVideo(BuildContext context) {
    final gyro = context.read<Sensor>();
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      setState(() {
        _errorText = 'Please enter a YouTube video URL';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    Navigator.push(
      context,
      platformPageRoute(
        context: context,
        builder: (context) {
          return VideoPlayerScreen(
            url: url,
            gestureTracker: GestureTracker(GyroscopeService(gyro)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: PlatformText("Handsfree video player"),
        trailingActions: [
          PlatformIconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                platformPageRoute(
                  context: context,
                  builder: (context) => const TutorialScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UrlInputField(
              controller: _urlController,
              errorText: _errorText,
            ),
            const SizedBox(height: 10),
            _PlayButton(onPressed: () => _playVideo(context)),
          ],
        ),
      ),
    );
  }
}

/// A text input field for entering a YouTube video URL.
///
/// Displays an error message if [errorText] is not null.
class _UrlInputField extends StatelessWidget {
  /// Controller for the text field.
  final TextEditingController controller;

  /// Error message to display below the field.
  final String? errorText;

  /// Creates a [_UrlInputField].
  const _UrlInputField({
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
      child: Column(
        children: [
          PlatformTextField(
            controller: controller,
            hintText: 'Enter YouTube video URL',
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                errorText!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}

/// A button that triggers video playback when pressed.
class _PlayButton extends StatelessWidget {
  /// Callback to invoke when the button is pressed.
  final VoidCallback onPressed;

  /// Creates a [_PlayButton].
  const _PlayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return PlatformElevatedButton(
      onPressed: onPressed,
      child: PlatformText("Play video"),
    );
  }
}
