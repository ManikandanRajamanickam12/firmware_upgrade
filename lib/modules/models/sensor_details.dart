import 'package:firmware/modules/models/metrics_data.dart';
import 'package:firmware/modules/models/models.dart';
import 'package:firmware/page/constants.dart';

class SensorDetails {
  final SensorCommand command;
  final PendingStatus pendingStatus;
  final SessionStatus sessionStatus;
  final SensorStatus sensorStatus;
  final String statusBytes;
  final int batteryLevel;
  final String sensorToken;
  final int utcTime;
  final int startTime;
  int currentReadAddress;
  int currentWriteAddress;
  final int ecgAmpThreshold;
  final String firmwareVersion;
  int pendingReads;

  SensorDetails(
    this.command, {
    required this.pendingStatus,
    required this.sessionStatus,
    required this.sensorStatus,
    required this.statusBytes,
    required this.batteryLevel,
    required this.sensorToken,
    required this.utcTime,
    required this.startTime,
    required this.currentReadAddress,
    required this.currentWriteAddress,
    required this.ecgAmpThreshold,
    required this.firmwareVersion,
    required this.pendingReads,
  });

// TODO use all lowercase for keys? mismatch in capitalisation can cause issues
// TODO pendingstatus, currentreadaddress, utctime INSTEAD OF pendingStatus, currentReadAddress
// TODO this can be created as an internal standard created for developer convenience
  Map<String, String> toDict() {
    return {
      "command": command.name.toString(),
      "pending_status": pendingStatus.name.toString(),
      "session_status": sessionStatus.name.toString(),
      "sensor_status": sensorStatus.name.toString(),
      "status_bytes": statusBytes.toString(),
      "battery_level": batteryLevel.toString(),
      "sensor_token": sensorToken,
      "utc_time": utcTime.toString(),
      "start_time": startTime.toString(),
      "currentReadAddress": currentReadAddress.toString(),
      "currentWriteAddress": currentWriteAddress.toString(),
      "ecgAmpThreshold": ecgAmpThreshold.toString(),
      "firmwareVersion": firmwareVersion,
      "pendingReads": pendingReads.toString(),
    };
  }

  static SensorDetails fromInfoResponse(InfoResponse response) {
    return SensorDetails(response.command,
        pendingStatus: response.pendingStatus,
        sessionStatus: response.sessionStatus,
        sensorStatus: response.sensorStatus,
        statusBytes: response.statusBytes,
        batteryLevel: response.batteryLevel,
        sensorToken: response.sensorToken,
        utcTime: response.utcTime,
        startTime: response.startTime,
        currentReadAddress: response.currentReadAddress,
        currentWriteAddress: response.currentWriteAddress,
        ecgAmpThreshold: response.ecgAmpThreshold,
        firmwareVersion: response.firmwareVersion,
        pendingReads: response.pendingReads);
  }
}
