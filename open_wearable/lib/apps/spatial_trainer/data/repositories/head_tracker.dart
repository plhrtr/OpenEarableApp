import 'package:flutter_soloud/flutter_soloud.dart';

class HeadTracker {
  final _soloud = SoLoud.instance;

  /// Updates the 3D position of the audio listener.
  /// [posX], [posY], and [posZ] are the intended spatial coordinates.
  void _updateListenerPosition(double posX, double posY, double posZ) {
    _soloud.set3dListenerPosition(posX, posY, posZ);
  }
}
