import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A screen that displays a tutorial for using the Handsfree YouTube Player app.
///
/// This tutorial explains how to get started and describes the gesture controls
/// available for handsfree video playback.
class TutorialScreen extends StatelessWidget {
  /// Creates a [TutorialScreen].
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: PlatformText("How to use?"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlatformText(
                "Getting Started",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _buildStep(
                context,
                icon: Icons.link,
                text:
                    "Copy the URL of your desired YouTube video and paste it into the text field.",
              ),
              _buildStep(
                context,
                icon: Icons.play_arrow,
                text: "Tap 'Play video' to start.",
              ),
              SizedBox(height: 28),
              PlatformText(
                "Gesture Controls",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    spacing: 8,
                    children: [
                      _buildGestureRow(
                        asset:
                            "lib/apps/handsfree_youtube_player/assets/face_up.svg",
                        description:
                            "Quickly nod your head up and down to toggle play/pause.",
                      ),
                      Divider(),
                      _buildGestureRow(
                        asset:
                            "lib/apps/handsfree_youtube_player/assets/face_left.svg",
                        description:
                            "Quickly turn your head left and return to center to rewind 30 seconds.",
                      ),
                      Divider(),
                      _buildGestureRow(
                        asset:
                            "lib/apps/handsfree_youtube_player/assets/face_right.svg",
                        description:
                            "Quickly turn your head right and return to center to skip forward 30 seconds.",
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: PlatformText(
                      "Tip: It may take a few tries to master the gestures. Try to make quick and distinct movements.",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Center(
                child: PlatformElevatedButton(
                  child: PlatformText("Got it!"),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a step row for the getting started section.
  ///
  /// [icon] is the icon to display.
  /// [text] is the description of the step.
  Widget _buildStep(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: PlatformText(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a row describing a gesture control.
  ///
  /// [asset] is the path to the SVG asset representing the gesture.
  /// [description] is the text explaining the gesture's function.
  Widget _buildGestureRow({
    required String asset,
    required String description,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          asset,
          width: 64,
          height: 64,
          colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
        ),
        SizedBox(width: 16),
        Expanded(
          child: PlatformText(
            description,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
