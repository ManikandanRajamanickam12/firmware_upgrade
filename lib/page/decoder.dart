import 'dart:developer';

import 'package:firmware/modules/models/metrics_data.dart';
import 'package:firmware/modules/models/models.dart';
import 'package:firmware/page/becon_decoder.dart';
import 'package:firmware/page/constants.dart';

class Decoder {
  static bool isInfoResponse(String hex) {
    return (hex.isNotEmpty && hex.length == kInfoResponseStringLength);
  }

  static bool isReadResponse(String hex) {
    return (hex.isNotEmpty && hex.length == kReadResponseStringLength);
  }

  static bool isMetricsResponse(String hex) {
    return (hex.isNotEmpty && hex.length == kMetricsResponseStringLength);
  }

  static bool isECGStream(String hex) {
    return (hex.isNotEmpty && hex.length == kECGStreamStringLength);
  }

  static bool isErrorResponse(String hex) {
    return (hex.isNotEmpty && hex.length == kErrorResponseStringLength);
  }

  static String bytesToHex(List<int> intData) {
    String hexData = '';
    for (var element in intData) {
      hexData += element.toRadixString(16).padLeft(2, '0').toUpperCase();
    }
    return hexData;
  }

  static DecodedResponse parseResponse(List<int> bytes) {
    String hex = Decoder.bytesToHex(bytes);
    print(hex);
    if (isInfoResponse(hex)) {
      log('INFO RESPONSE');
      return parseInfoResponse(hex);
    } else if (isMetricsResponse(hex)) {
      log('METRICS RESPONSE - $hex');
      return parseMetricsResponse(hex);
    } else if (isReadResponse(hex)) {
      log('READ RESPONSE');
      return parseReadResponse(hex);
    } else if (BeaconDecoder.isBeaconResponse(hex)) {
      log('BEACON RESPONSE');
      return BeaconDecoder.parseBeaconResponse(hex);
    } else if (isErrorResponse(hex)) {
      log('ERROR RESPONSE');
      return parseErrorResponse(hex);
    } else {
      log('UNKNOWN RESPONSE, length: ${hex.length.toString()}');
      return const UnknownResponse();
    }
  }

  static InfoResponse parseInfoResponse(String hex) {
    int nibble = int.parse(hex.substring(2, 3), radix: 16);
    int batteryLevel = int.parse(hex.substring(3, 4), radix: 16) * 10;
    int utcTime = int.parse(hex.substring(12, 20), radix: 16);
    int startTime = int.parse(hex.substring(20, 28), radix: 16);
    int currentReadAddress = int.parse(hex.substring(28, 36), radix: 16);
    int currentWriteAddress = int.parse(hex.substring(36, 44), radix: 16);
    int pendingReads =
        ((currentWriteAddress - currentReadAddress) ~/ kReadDataBytes);
    int ecgAmpThreshold = 0;
    int verA = int.parse(hex.substring(44, 46), radix: 16);
    int verB = int.parse(hex.substring(46, 48), radix: 16);
    int verC = int.parse(hex.substring(48, 50), radix: 16);

    String commandHex = hex.substring(0, 2);
    String statusBytes =
        "${hex.substring(2, 3)},${int.parse(hex.substring(2, 3), radix: 16)}";
    String sensorToken = hex.substring(4, 6) +
        hex.substring(6, 8) +
        hex.substring(8, 10) +
        hex.substring(10, 12);
    String firmwareVersion = "$verA.$verB.$verC";

    PendingStatus pendingStatus =
        (nibble / 4) % 2 == 1 ? PendingStatus.pending : PendingStatus.noPending;

    SessionStatus sessionStatus = (nibble / 2).floor() % 2 == 1
        ? SessionStatus.running
        : SessionStatus.notRunning;

    SensorStatus sensorStatus = (nibble / 1).floor() % 2 == 1
        ? SensorStatus.running
        : SensorStatus.notRunning;

    log("Session status - ${sessionStatus.name}");
    return InfoResponse(
      getCommandName(commandHex),
      pendingStatus: pendingStatus,
      sessionStatus: sessionStatus,
      sensorStatus: sensorStatus,
      statusBytes: statusBytes,
      batteryLevel: batteryLevel,
      sensorToken: sensorToken,
      utcTime: utcTime,
      startTime: startTime,
      currentReadAddress: currentReadAddress,
      currentWriteAddress: currentWriteAddress,
      pendingReads: pendingReads,
      ecgAmpThreshold: ecgAmpThreshold,
      firmwareVersion: firmwareVersion,
    );
  }

  static MetricsResponse parseMetricsResponse(String hex) {
    return MetricsResponse(
        heartRate: int.parse(hex.substring(2, 4), radix: 16),
        stepCount: int.parse(hex.substring(4, 6), radix: 16));
  }

  static ReadResponse parseReadResponse(String hex) {
    return ReadResponse(hexData: hex);
  }

  static ErrorResponse parseErrorResponse(String hex) {
    return ErrorResponse(
        command: getCommandName(hex.substring(0, 2)),
        errorCode: hex.substring(2, 4));
  }

  static SensorCommand getCommandName(String commandHex) {
    SensorCommand sensorCommand = SensorCommand.unknown;

    commandToHex.forEach((SensorCommand key, String value) {
      if (value == commandHex) sensorCommand = key;
    });

    return sensorCommand;
  }
}
