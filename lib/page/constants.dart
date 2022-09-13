import 'package:firmware/modules/models/models.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

final Uuid serviceUUID = Uuid.parse('6e400001-b5a3-f393-e0a9-e50e24dcca9e');
final Uuid rxCharUUID = Uuid.parse('6e400002-b5a3-f393-e0a9-e50e24dcca9e');
final Uuid txCharUUID = Uuid.parse('6e400003-b5a3-f393-e0a9-e50e24dcca9e');
const int kReadDataBytes = 100;
const int kReadResponseStringLength = 200;
const int kInfoResponseStringLength = 50;
const int kMetricsResponseStringLength = 6;
const int kECGStreamStringLength = 70;
const int kErrorResponseStringLength = 4;
const int kBeaconResponseStringLength = 30;
const int kMaxResponseIntervalSecs = 1;

// enum SessionStatus { running, notRunning }
enum SensorStatus { running, notRunning }

enum SessionStatus { running, notRunning }

enum PendingStatus { pending, noPending }

enum SensorCommand {
  reset,
  status,
  start,
  stop,
  read,
  time,
  token,
  unknown,
  dfu
}

const Map<SensorCommand, String> commandToString = {
  SensorCommand.reset: '0',
  SensorCommand.status: '1',
  SensorCommand.start: '2',
  SensorCommand.stop: '3',
  SensorCommand.read: '5',
  SensorCommand.time: 'T',
  SensorCommand.token: 'K',
  SensorCommand.dfu: "F"
};

const Map<SensorCommand, String> commandToHex = {
  SensorCommand.reset: '30',
  SensorCommand.status: '31',
  SensorCommand.start: '32',
  SensorCommand.stop: '33',
  SensorCommand.read: '35',
  SensorCommand.time: '54',
  SensorCommand.token: '4B',
};
