sealed class VideoPlayerEvent {}

class VideoTogglePauseEvent extends VideoPlayerEvent {}

class VideoSkipForwardEvent extends VideoPlayerEvent {}

class VideoSkipBackwardEvent extends VideoPlayerEvent {}

class VideoNewURLEvent extends VideoPlayerEvent {
  final String newURL;

  VideoNewURLEvent(this.newURL);
}
