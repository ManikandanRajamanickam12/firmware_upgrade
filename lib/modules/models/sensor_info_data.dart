import 'package:firmware/modules/models/sensor_details.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class SensorInfoData {
  final SensorDetails sensorDetails;

  DiscoveredDevice? device;

  SensorInfoData({
    required this.sensorDetails,
    this.device,
  });
}
