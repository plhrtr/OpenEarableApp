import 'dart:async';

import 'package:open_earable_flutter/open_earable_flutter.dart';

/// Represents a single gyroscope sample.
class GyroscopeSample {
  /// The roll angle in degrees.
  final double rollDPS;

  /// The pitch angle in degrees.
  final double pitchDPS;

  /// The yaw angle in degrees.
  final double yawDPS;

  final DateTime timestamp = DateTime.now();

  /// Creates a [GyroscopeSample] with the given data.
  GyroscopeSample({
    required this.rollDPS,
    required this.pitchDPS,
    required this.yawDPS,
  });

  @override
  String toString() =>
      "Roll dps: $rollDPS | Pitch dps: $pitchDPS | Yaw dps: $yawDPS";
}

/// A service that provides access to gyroscope sensor data and streams it as [GyroscopeSample]s.
class GyroscopeService {
  /// The gyroscope sensor instance.
  final Sensor _gyroscope;

  /// Controller for broadcasting gyroscope sample data.
  final StreamController<GyroscopeSample> _gyroscopeStreamController =
      StreamController.broadcast();

  /// Creates a [GyroscopeService] and starts listening to the gyroscope sensor stream.
  GyroscopeService(this._gyroscope) {
    // listen to the data stream
    _gyroscope.sensorStream.listen((value) {
      if (value is SensorDoubleValue) {
        _gyroscopeStreamController.add(
          GyroscopeSample(
            yawDPS: value.values[0],
            rollDPS: value.values[1],
            pitchDPS: value.values[2],
          ),
        );
      }
    });

    // enable the data stream
    SensorConfiguration config = _gyroscope.relatedConfigurations.first;

    // configure sensor to stream data, at a middle ground frequency.
    if (config is ConfigurableSensorConfiguration &&
        config.availableOptions.contains(StreamSensorConfigOption())) {
      Iterable<ConfigurableSensorConfigurationValue> streamConfigValues =
          config.values.where(
        (value) =>
            value.options.any((option) => option is StreamSensorConfigOption),
      );

      ConfigurableSensorConfigurationValue streamConfigValue =
          streamConfigValues.toList()[(streamConfigValues.length / 2).round()];

      config.setConfiguration(streamConfigValue);
    }
  }

  /// Listen to the gyroscope data stream.
  ///
  /// The [callback] function is called whenever a new [GyroscopeSample] is available.
  StreamSubscription<GyroscopeSample> listen(
    void Function(GyroscopeSample) callback,
  ) {
    return _gyroscopeStreamController.stream.listen(callback);
  }
}
