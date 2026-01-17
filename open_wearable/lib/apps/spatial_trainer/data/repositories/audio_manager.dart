import 'package:flutter_soloud/flutter_soloud.dart';

/// Manages audio playback for the spatial trainer app, including
/// initialization, sound effects, and spatial audio positioning.
class AudioManager {
  /// Singleton instance of SoLoud audio engine.
  final _soloud = SoLoud.instance;

  /// Audio source for the sound played when the spatial point is found.
  late final AudioSource _acceptSound;

  /// Audio source for the sound played on start up.
  late final AudioSource _startSound;

  /// Audio source for the sound placed in 3D space.
  late final AudioSource _spatialSound;

  /// Handle for the currently playing spatial sound.
  late final SoundHandle _currentSpatialTone;

  /// Initializes the audio engine and loads sound assets.
  Future<void> init() async {
    await _soloud.init();
    _acceptSound = await _soloud
        .loadAsset("lib/apps/spatial_trainer/assets/accept_sound.mp3");
    _startSound = await _soloud
        .loadAsset("lib/apps/spatial_trainer/assets/start_sound.mp3");
    _spatialSound = await _soloud
        .loadAsset("lib/apps/spatial_trainer/assets/spatial_sound.wav");
  }

  /// Plays the accept sound effect.
  void playAcceptSound() {
    _soloud.play(_acceptSound);
  }

  /// Plays the start sound effect.
  void playStartSound() {
    _soloud.play(_startSound);
  }

  /// Starts playing the spatial sound in a loop.
  ///
  /// [posX], [posY], and [posZ] are the intended spatial coordinates.
  void spawnNewSpatialSound(double posX, double posY, double posZ) async {
    _currentSpatialTone = await _soloud.play3d(
      _spatialSound,
      posX,
      posY,
      posZ,
      looping: true,
    );
  }

  /// Stops the currently playing spatial sound and resets listener position.
  void stopSpatialSound() {
    _soloud.set3dListenerPosition(0, 0, 0);
    if (_currentSpatialTone != null) {
      _soloud.stop(_currentSpatialTone);
    }
  }
}
