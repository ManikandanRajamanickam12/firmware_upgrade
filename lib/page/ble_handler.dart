import 'package:firmware/page/commander.dart';
import 'package:firmware/page/constants.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';

class BleHandler {
  static final BleHandler _client = BleHandler._internal();

  factory BleHandler() {
    return _client;
  }

  BleHandler._internal();

  static BleHandler get instance => _client;

  DiscoveredDevice? sensorDevice;
  StreamSubscription<DiscoveredDevice>? scanSubscription;
  StreamSubscription<BleStatus>? bleStatus;

  StreamSubscription<ConnectionStateUpdate>? connectionSubscription;

  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  Commander? commander;

  StreamSubscription<BleStatus>? bleStatusListener() {
    bleStatus = flutterReactiveBle.statusStream.listen(null);
    return bleStatus;
  }

  void connectToDevice(String deviceId) {
    scanSubscription!.cancel();
    connectionSubscription = flutterReactiveBle
        .connectToAdvertisingDevice(
            id: deviceId,
            withServices: [],
            prescanDuration: const Duration(seconds: 5),
            servicesWithCharacteristicsToDiscover: {
              serviceUUID: [rxCharUUID, txCharUUID]
            },
            connectionTimeout: const Duration(seconds: 10))
        .listen(null);
  }

  void scanForDevices() {
    scanSubscription =
        flutterReactiveBle.scanForDevices(withServices: []).listen((event) {});
  }

  void dispose() {
    flutterReactiveBle.deinitialize();
    connectionSubscription = null;
    scanSubscription = null;
    sensorDevice = null;
  }
}
