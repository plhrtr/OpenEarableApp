import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/handfree_video_player/data/repositories/gesture_tracker.dart';
import 'package:open_wearable/apps/handfree_video_player/data/services/gyroscope_service.dart';
import 'package:open_wearable/apps/handfree_video_player/ui/video_player/bloc/video_player_bloc.dart';
import 'package:open_wearable/apps/handfree_video_player/ui/video_player/bloc/video_player_state.dart';

class VideoPlayerScreen extends StatefulWidget {
  final SensorManager wearable;
  const VideoPlayerScreen({super.key, required this.wearable});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final sensors = widget.wearable.sensors;

    // Only show the app when the selected earable has an IMU Sensor
    if (sensors.any((s) => s.sensorName.contains("Accelerometer")) &&
        sensors.any((s) => s.sensorName.contains("Gyroscope"))) {
      Sensor gyro = sensors.firstWhere(
        (s) => s.sensorName.contains("Gyroscope"),
      );

      return RepositoryProvider(
        create: (context) => GestureTracker(GyroscopeService(gyro)),
        child: PlatformScaffold(
          appBar: PlatformAppBar(
            title: PlatformText("Handsfree video player"),
          ),
          body: BlocProvider(
            create: (context) => VideoPlayerBloc(context.read()),
            child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
              builder: (context, state) {
                return PlatformText("Handsfree video player");
              },
            ),
          ),
        ),
      );
    }
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: PlatformText("Handsfree PDF view"),
      ),
      body: Center(
        child: PlatformText("No gyroscope sensor found"),
      ),
    );
  }
}
