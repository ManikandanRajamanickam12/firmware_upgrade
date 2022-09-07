import 'package:firmware/modules/models/metrics_data.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

enum IdleDeviceStatus { offline, notRunning }

class LiveViewData {
  MetricsData? metricsData;
  DiscoveredDevice device;
  LiveViewData({this.metricsData, required this.device});
}
