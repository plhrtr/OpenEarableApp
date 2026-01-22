import 'dart:async';

import 'package:open_earable_flutter/open_earable_flutter.dart';

/// Represents a single gyroscope sample.
class AccelerometerSample {
  final double ax;

  final double ay;

  final double az;

  /// Creates a [AccelerometerSample] with the given data.
  AccelerometerSample({
    required this.ax,
    required this.ay,
    required this.az,
  });

  @override
  String toString() => "ax: $ax | ay: $ay | az: $az";
}

/// A service that provides access to gyroscope sensor data and streams it as [AccelerometerSample]s.
class AccelerometerService {
  /// The gyroscope sensor instance.
  final Sensor _accelerometer;

  /// Controller for broadcasting gyroscope sample data.
  final StreamController<AccelerometerSample> _accelerometerStreamController =
      StreamController.broadcast();

  /// Creates a [AccelerometerService] and starts listening to the gyroscope sensor stream.
  AccelerometerService(this._accelerometer) {
    // listen to the data stream
    _accelerometer.sensorStream.listen((value) {
      if (value is SensorDoubleValue) {
        final double ax = value.values[1];
        final double ay = value.values[0];
        final double az = value.values[2];

        _accelerometerStreamController.add(
          AccelerometerSample(ax: ax, ay: ay, az: az),
        );
      }
    });

    // enable the data stream
    SensorConfiguration config = _accelerometer.relatedConfigurations.first;

    if (config is ConfigurableSensorConfiguration &&
        config.availableOptions.contains(StreamSensorConfigOption())) {
      ConfigurableSensorConfigurationValue configValue =
          config.values.firstWhere(
        (value) =>
            value.options.any((option) => option is StreamSensorConfigOption),
      );
      config.setConfiguration(configValue);
    }
  }

  /// Listen to the gyroscope data stream.
  ///
  /// The [callback] function is called whenever a new [AccelerometerSample] is available.
  StreamSubscription<AccelerometerSample> listen(
    void Function(AccelerometerSample) callback,
  ) {
    return _accelerometerStreamController.stream.listen(callback);
  }
}
