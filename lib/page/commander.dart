import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firmware/modules/models/models.dart';
import 'package:firmware/page/ble_handler.dart';
import 'package:firmware/page/constants.dart';
import 'package:firmware/page/decoder.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:rxdart/rxdart.dart';

class Commander {
  DiscoveredDevice? sensorDevice;

  final FlutterReactiveBle flutterReactiveBle =
      BleHandler.instance.flutterReactiveBle;

  late QualifiedCharacteristic rxCharacteristic;
  late QualifiedCharacteristic txCharacteristic;

  late StreamSubscription dataSubscription;

  BehaviorSubject<DecodedResponse> responseStream =
      BehaviorSubject.seeded(const NoResponse());

  Commander(this.sensorDevice) {
    rxCharacteristic = QualifiedCharacteristic(
        serviceId: serviceUUID,
        characteristicId: rxCharUUID,
        deviceId: sensorDevice!.id);

    txCharacteristic = QualifiedCharacteristic(
        serviceId: serviceUUID,
        characteristicId: txCharUUID,
        deviceId: sensorDevice!.id);

    dataSubscription = flutterReactiveBle
        .subscribeToCharacteristic(txCharacteristic)
        .listen((bytes) {
      dev.log('COMMANDER: Response length ${bytes.length.toString()} bytes');

      String hex = Decoder.bytesToHex(bytes);
      if (hex.isEmpty) {
        print("no hex data");
      }
      print(hex.length);

      responseStream.add(Decoder.parseResponse(bytes));
    }, onError: (dynamic error) {
      dev.log("error - ${error.toString()}");
    });
  }

  // void charFunction(List<int> bytes) {
  //   dev.log('COMMANDER: Response length ${bytes.length.toString()} bytes');
  //
  //   String hex = Decoder.bytesToHex(bytes);
  //
  //   // TODO where is the code to handle all other cases? what happens if data is actually metrics response?
  //   if (!Decoder.isMetricsResponse(hex)) {
  //     responseStream.add(Decoder.parseResponse(bytes));
  //   } else {
  //     dev.log(hex);
  //   }
  // }

  void getSensorInfo() async {
    dev.log('COMMANDER: Get sensor info');
    await flutterReactiveBle.writeCharacteristicWithoutResponse(
        rxCharacteristic,
        value: utf8.encode(commandToString[SensorCommand.status]!));
  }

  void setFirmwareUpgrade() async {
    dev.log('COMMANDER: Firmware upgrade');
    await flutterReactiveBle.writeCharacteristicWithoutResponse(
        rxCharacteristic,
        value: utf8.encode(commandToString[SensorCommand.dfu]!));
  }

  void resetSensor() async {
    dev.log('COMMANDER: Reset sensor');
    await flutterReactiveBle.writeCharacteristicWithoutResponse(
        rxCharacteristic,
        value: utf8.encode(commandToString[SensorCommand.reset]!));
  }

  void startSession() async {
    dev.log('COMMANDER: Starting session');
    await flutterReactiveBle.writeCharacteristicWithoutResponse(
        rxCharacteristic,
        value: utf8.encode(commandToString[SensorCommand.start]!));
  }

  void stopSession() async {
    dev.log('COMMANDER: Stopping session');
    await flutterReactiveBle.writeCharacteristicWithoutResponse(
        rxCharacteristic,
        value: utf8.encode(commandToString[SensorCommand.stop]!));
  }

  void readData() async {
    dev.log('COMMANDER: Reading data');
    await flutterReactiveBle
        .writeCharacteristicWithResponse(rxCharacteristic,
            value: utf8.encode(commandToString[SensorCommand.read]!))
        .onError((error, stackTrace) {
      dev.log("error - ${error.toString()}");
    });
  }

  void setTime(List<int> time) async {
    dev.log('COMMANDER: Set Time');
    await flutterReactiveBle
        .writeCharacteristicWithoutResponse(rxCharacteristic, value: time);
  }

  void setToken(List<int> token) async {
    dev.log('COMMANDER: Set Token');
    await flutterReactiveBle
        .writeCharacteristicWithoutResponse(rxCharacteristic, value: token);
  }

  void cancelDataSubscription() {
    dataSubscription.cancel();
  }

  void cancelResponseStream() {
    responseStream.close();
  }
}
