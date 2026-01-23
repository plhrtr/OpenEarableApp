import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/handsfree_youtube_player/data/repositories/gesture_tracker.dart';
import 'package:open_wearable/apps/handsfree_youtube_player/data/services/gyroscope_service.dart';
import 'package:open_wearable/apps/handsfree_youtube_player/ui/tutorial/tutorial_screen.dart';
import 'package:open_wearable/apps/handsfree_youtube_player/ui/video_player/video_player_screen.dart';
import 'package:provider/provider.dart';

class VideoSelectionScreen extends StatefulWidget {
  const VideoSelectionScreen({super.key});

  @override
  State<VideoSelectionScreen> createState() => _VideoSelectionScreenState();
}

class _VideoSelectionScreenState extends State<VideoSelectionScreen> {
  final TextEditingController _urlController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

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

class _UrlInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

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

class _PlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PlayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return PlatformElevatedButton(
      onPressed: onPressed,
      child: PlatformText("Play video"),
    );
  }
}
