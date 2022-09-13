

import 'package:firmware/page/constants.dart';

class MetricsData {
  String command;
  String sensorToken;
  PendingStatus pendingStatus;
  SessionStatus sessionStatus;
  SensorStatus sensorStatus;
  int relativeTime;
  int rr;
  int hr;
  int acceleration;
  int stepCount;
  bool isDataAvailable;
  int battery;
  MetricsData(
      {required this.command,
      required this.sensorToken,
      required this.pendingStatus,
      required this.sessionStatus,
      required this.sensorStatus,
      required this.relativeTime,
      required this.rr,
      required this.hr,
      required this.acceleration,
      required this.stepCount,
      required this.isDataAvailable,
      required this.battery});
}
