import 'package:equatable/equatable.dart';
import 'package:firmware/modules/models/metrics_data.dart';
import 'package:firmware/page/constants.dart';

abstract class DecodedResponse extends Equatable {
  const DecodedResponse();
}

class BeaconResponse extends DecodedResponse {
  final String command;
  final int relativeTime;
  final String sensorToken;
  final int hr;
  final int acceleration;
  final int stepCount;
  final int battery;

  const BeaconResponse(
      {required this.command,
      required this.relativeTime,
      required this.sensorToken,
      required this.hr,
      required this.acceleration,
      required this.stepCount,
      required this.battery});

  @override
  List<Object?> get props => [
        command,
        relativeTime,
        sensorToken,
        hr,
        acceleration,
        stepCount,
      ];
}

class InfoResponse extends DecodedResponse {
  final SensorCommand command;
  final PendingStatus pendingStatus;
  final SessionStatus sessionStatus;
  final SensorStatus sensorStatus;
  final String statusBytes;
  final int batteryLevel;
  final String sensorToken;
  final int utcTime;
  final int startTime;
  final int currentReadAddress;
  final int currentWriteAddress;
  final int ecgAmpThreshold;
  final String firmwareVersion;
  final int pendingReads;

  const InfoResponse(
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

  Map<String, String> toDict() {
    return {
      "command": command.name.toString(),
      "pendingStatus": pendingStatus.name.toString(),
      "sessionStatus": sessionStatus.name.toString(),
      "sensorStatus": sensorStatus.name.toString(),
      "Statusbytes": statusBytes.toString(),
      "batteryLevel": batteryLevel.toString(),
      "sensorToken": sensorToken,
      "utcTime": utcTime.toString(),
      "startTime": startTime.toString(),
      "currentReadAddress": currentReadAddress.toString(),
      "currentWriteAddress": currentWriteAddress.toString(),
      "ecgAmpThreshold": ecgAmpThreshold.toString(),
      "firmwareVersion": firmwareVersion,
      "pendingReads": pendingReads.toString(),
    };
  }

  @override
  List<Object?> get props => [
        pendingStatus,
        sessionStatus,
        sensorStatus,
        statusBytes,
        batteryLevel,
        sensorToken,
        utcTime,
        startTime,
        currentReadAddress,
        currentWriteAddress,
        ecgAmpThreshold,
        firmwareVersion,
        pendingReads,
      ];
}

class MetricsResponse extends DecodedResponse {
  final int heartRate;
  final int stepCount;

  const MetricsResponse({required this.heartRate, required this.stepCount});

  Map<String, String> toDict() {
    return {
      "heartRate": heartRate.toString(),
      "stepCount": stepCount.toString(),
    };
  }

  @override
  List<Object?> get props => [heartRate, stepCount];
}

class ReadResponse extends DecodedResponse {
  final String hexData;

  const ReadResponse({required this.hexData});

  @override
  List<Object?> get props => [hexData];
}

class ErrorResponse extends DecodedResponse {
  final SensorCommand command;
  final String errorCode;

  const ErrorResponse({required this.command, required this.errorCode});

  @override
  List<Object?> get props => [command, errorCode];
}

class UnknownResponse extends DecodedResponse {
  const UnknownResponse();

  @override
  List<Object?> get props => [];
}

class NoResponse extends DecodedResponse {
  const NoResponse();

  @override
  List<Object?> get props => [];
}
