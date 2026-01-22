import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_wearable/apps/handsfree_video_player/data/repositories/gesture_tracker.dart';
import 'package:open_wearable/apps/handsfree_video_player/ui/video_player/bloc/video_player_events.dart';
import 'package:open_wearable/apps/handsfree_video_player/ui/video_player/bloc/video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  final GestureTracker _gestureTracker;
  VideoPlayerBloc(this._gestureTracker) : super(VideoPlayerInitial()) {
    _gestureTracker.listen(
      (gesture) {
        print(gesture);
        switch (gesture) {
          case Gesture.yawLeft:
            add(VideoSkipBackwardEvent());
            break;
          case Gesture.yawRight:
            add(VideoSkipForwardEvent());
            break;
          case Gesture.pitchUp:
            add(VideoTogglePauseEvent());
            break;
        }
      },
    );

    on<VideoTogglePauseEvent>((event, emit) {
      // TODO: Implement event handling logic here
    });
    on<VideoSkipForwardEvent>((event, emit) {
      // TODO: Implement event handling logic here
    });
    on<VideoSkipBackwardEvent>((event, emit) {
      // TODO: Implement event handling logic here
    });
    on<VideoNewURLEvent>((event, emit) {
      // TODO: Implement event handling logic here
    });
  }

  @override
  Future<void> close() {
    _gestureTracker.close(); // Close your stream here
    return super.close();
  }
}
