import 'dart:async';

import 'package:open_wearable/apps/handsfree_youtube_player/data/services/gyroscope_service.dart';

/// Enum representing the possible gestures detected by the gesture tracker.
enum Gesture {
  /// Head turned quickly to the left.
  yawLeft,

  /// Head turned quickly to the right.
  yawRight,

  /// Head quickly nodded up.
  pitchUp,
}

/// A fixed-size circular buffer for storing elements of type [T].
///
/// When the buffer is full, new elements overwrite the oldest ones.
class CircularBuffer<T> {
  final List<T?> _buffer;
  int _head = 0;
  int _size = 0;
  final int capacity;

  /// Creates a [CircularBuffer] with the given [capacity].
  CircularBuffer(this.capacity) : _buffer = List<T?>.filled(capacity, null);

  /// Adds an [item] to the buffer, overwriting the oldest element if full.
  void add(T item) {
    _buffer[_head] = item;
    _head = (_head + 1) % capacity;
    if (_size < capacity) {
      _size++;
    }
  }

  /// Returns a list representation of the buffer.
  ///
  /// Oldest elements are before newer elements.
  List<T> toList() {
    if (_size == 0) return [];
    List<T> result = [];
    for (int i = 0; i < _size; i++) {
      int idx = (_head - _size + i) % capacity;
      if (idx < 0) idx += capacity;
      if (_buffer[idx] != null) {
        result.add(_buffer[idx] as T);
      }
    }
    return result;
  }

  /// Returns true if the buffer is full.
  bool get isFull => _size == capacity;

  /// Returns true if the buffer is empty.
  bool get isEmpty => _size == 0;

  /// Returns the current number of elements in the buffer.
  int get length => _size;
}

/// Tracks head gestures using gyroscope data and emits detected gestures.
///
/// Listens to a [GyroscopeService] and processes gyroscope samples to detect
/// gestures, using overlapping sampling windows. Detected gestures are emitted
/// through a broadcast stream.
class GestureTracker {
  /// The length of a data window used for gesture recognition in ms.
  static final featureExtractionWindowLength = 300;

  /// The cooldown period between gesture recognitions in ms.
  static final gestureCooldown = 500;

  /// Threshold for detecting yaw gestures (degrees per second).
  static final double yawThreshold = 150.0;

  /// Threshold for detecting pitch gestures (degrees per second).
  static final double pitchThreshold = 70.0;

  /// Maximum allowed duration for a gesture in ms.
  static final int maxGestureDurationMs = 250;

  final GyroscopeService _gyroScopeService;
  late final StreamSubscription<GyroscopeSample> _gyroSubscription;

  /// Stream controller for broadcasting detected gestures.
  final StreamController<Gesture> _gestureStreamController =
      StreamController.broadcast();

  /// Buffer for storing recent gyroscope samples.
  final buffer =
      CircularBuffer<GyroscopeSample>(2 * featureExtractionWindowLength);

  /// Timestamp of the last detected gesture.
  DateTime _lastGestureTime = DateTime.now();

  /// Creates a [GestureTracker] that listens to the provided [GyroscopeService].
  ///
  /// Periodically processes buffered gyroscope data to detect gestures.
  GestureTracker(this._gyroScopeService) {
    // add to extraction window or extract the gesture
    _gyroSubscription = _gyroScopeService.listen(buffer.add);
    // execute gesture extraction with overlapping sampling windows
    Timer.periodic(
        Duration(milliseconds: (featureExtractionWindowLength / 2).round()),
        (Timer t) {
      final window = buffer
          .toList()
          .where(
            (sample) =>
                sample.timestamp.millisecondsSinceEpoch >
                (DateTime.now().millisecondsSinceEpoch -
                    featureExtractionWindowLength),
          )
          .toList();

      _extractGesture(window);
    });
  }

  /// Listen to the gesture data stream.
  ///
  /// The [callback] function is called whenever a new [Gesture] is executed by the user.
  void listen(void Function(Gesture) callback) {
    _gestureStreamController.stream.listen(callback);
  }

  /// Closes this repository after it's no longer in use.
  ///
  /// Cancels all subscriptions to sensor data and also closes the gesture stream.
  void close() {
    _gyroSubscription.cancel();
    _gestureStreamController.close();
  }

  /// Extracts the gesture from the sampling window if there is one.
  ///
  /// If a gesture is detected, it is added as an event to the stream.
  void _extractGesture(List<GyroscopeSample> window) {
    if (window.isEmpty ||
        _lastGestureTime.millisecondsSinceEpoch >
            DateTime.now().millisecondsSinceEpoch - gestureCooldown) {
      return;
    }

    // Find max and min yawDPS in the window
    double maxYaw = window.first.yawDPS;
    double minYaw = window.first.yawDPS;
    double maxPitch = window.first.pitchDPS;
    double minPitch = window.first.pitchDPS;
    double maxRoll = window.first.rollDPS;
    double minRoll = window.first.rollDPS;
    int maxYawIdx = 0, minYawIdx = 0, maxPitchIdx = 0, minPitchIdx = 0;

    for (int i = 0; i < window.length; i++) {
      if (window[i].yawDPS > maxYaw) {
        maxYaw = window[i].yawDPS;
        maxYawIdx = i;
      }
      if (window[i].yawDPS < minYaw) {
        minYaw = window[i].yawDPS;
        minYawIdx = i;
      }

      if (window[i].rollDPS > maxPitch) {
        maxPitch = window[i].pitchDPS;
        maxPitchIdx = i;
      }
      if (window[i].rollDPS < minPitch) {
        minPitch = window[i].pitchDPS;
        minPitchIdx = i;
      }

      if (window[i].rollDPS > maxRoll) {
        maxRoll = window[i].rollDPS;
      }
      if (window[i].rollDPS < minRoll) {
        minRoll = window[i].rollDPS;
      }
    }

    // Check for right-left gesture
    if (maxYaw > yawThreshold &&
        minYaw < -(yawThreshold / 2) &&
        maxYawIdx < minYawIdx) {
      final start = window[maxYawIdx].timestamp;
      final end = window[minYawIdx].timestamp;

      if (end.difference(start).inMilliseconds <= maxGestureDurationMs) {
        _lastGestureTime = DateTime.now();
        _gestureStreamController.add(Gesture.yawRight);
        return;
      }
    }

    // Check for left-right gesture
    if (minYaw < -yawThreshold &&
        maxYaw > (yawThreshold / 2) &&
        minYawIdx < maxYawIdx) {
      final start = window[minYawIdx].timestamp;
      final end = window[maxYawIdx].timestamp;

      if (end.difference(start).inMilliseconds <= maxGestureDurationMs) {
        _lastGestureTime = DateTime.now();
        _gestureStreamController.add(Gesture.yawLeft);
        return;
      }
    }

    // Check for pitch-up-down gesture
    if (minPitch < -pitchThreshold &&
        maxPitch > (pitchThreshold / 3) &&
        minPitchIdx < maxPitchIdx) {
      final start = window[minPitchIdx].timestamp;
      final end = window[maxPitchIdx].timestamp;

      if (end.difference(start).inMilliseconds <= maxGestureDurationMs) {
        _lastGestureTime = DateTime.now();
        _gestureStreamController.add(Gesture.pitchUp);
        return;
      }
    }
  }
}
