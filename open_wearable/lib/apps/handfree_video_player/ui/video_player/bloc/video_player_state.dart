sealed class VideoPlayerState {}

class VideoPlayerInitial extends VideoPlayerState {}

class VideoPlayerPlaying extends VideoPlayerState {
  final bool isPaused;
  final String currentURL;

  VideoPlayerPlaying(this.isPaused, this.currentURL);
}
