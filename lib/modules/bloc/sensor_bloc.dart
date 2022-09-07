import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firmware/modules/models/dfu.dart';
import 'package:firmware/modules/models/live_view_data.dart';
import 'package:firmware/modules/models/models.dart';
import 'package:firmware/page/app_device.dart';
import 'package:firmware/page/becon_decoder.dart';
import 'package:firmware/page/ble_handler.dart';
import 'package:firmware/page/commander.dart';
import 'package:firmware/page/decoder.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:nordic_dfu/nordic_dfu.dart';
import 'package:rxdart/rxdart.dart';
part 'sensor_event.dart';
part 'sensor_state.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  static final _client = SensorBloc._internal();

  factory SensorBloc() {
    return _client;
  }

  static SensorBloc get instance => _client;

  final BehaviorSubject<Map<String, LiveViewData>?> knownDeviceStream =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<dynamic> downloadfileStream = BehaviorSubject.seeded(0);
  bool dfuRunning = true;
  List<DFU> DFUdevices = [];
  String assetLocation = "";

  int max = 0;
  int index = 0;
  SensorBloc._internal() : super(SensorInitialState()) {
    on<SensorSearchEvent>((event, emit) async {
      searchDevices();

      emit(SensorLiveViewState());
    });

    on<SensorConnectEvent>((event, emit) async {
      // emit(const SensorLoadingState(message: "Connecting to the device"));

      BleHandler.instance.scanSubscription?.cancel();

      connectDevice(event.device);

      BleHandler.instance.connectionSubscription!.onData((updates) async {
        /* SENSOR CONNECTED */

        if (updates.connectionState == DeviceConnectionState.connected) {
          BleHandler.instance.sensorDevice = event.device;
          add(SensorUpgradeHelperEvent());
          print("emmit");
        }

        /* SENSOR DISCONNECTED */

        // else if (updates.connectionState ==
        //     DeviceConnectionState.disconnected) {
        //   add(const SensorSearchEvent());
        // }
      });

      BleHandler.instance.connectionSubscription!.onError((dynamic error) {
        log('>> ${error.toString()}');
      });
    });
    on<SensorUpgradeHelperEvent>((event, emit) async {
      emit(SensorUpgradeFirmwareState());
    });

    on<SensorUpgradeFirmwareEvent>((event, emit) async {
      BleHandler.instance.commander =
          Commander(BleHandler.instance.sensorDevice);
      assetLocation = event.asset;
      BleHandler.instance.commander?.setFirmwareUpgrade();
      Future.delayed(Duration(seconds: 5), () {
        doAction();
      });
    });
  }
  void doAction() {
    Future.delayed(Duration(seconds: 2), () {
      disconnectDevice();
    });
    Future.delayed(Duration(seconds: 5), () {
      print("upgrade start");
      BleHandler.instance.scanForDevices();
      BleHandler.instance.scanSubscription?.onData((device) {
        if (device.name.startsWith("Dfu")) {
          DFUdevices.add(
              DFU(name: device.name, id: device.id, rssi: device.rssi));
          Future.delayed(Duration(seconds: 3), () {
            connectDFUDevice(device);
          });
          Future.delayed(Duration(seconds: 10), () {
            upgradeFirmware();
          });
        } else
          print("not connected to dfu ${device.name}");
      });
    });
  }

  upgradeFirmware() {
    max = DFUdevices[0].rssi!;
    index = 0;
    for (int i = 0; i < DFUdevices.length; i++) {
      if (DFUdevices[i].rssi! > max) {
        max = DFUdevices[i].rssi!;
        index = i;
      } else {
        max = DFUdevices[0].rssi!;
      }
    }
    print(max);
    print(index);
    print(DFUdevices.toString());
    doDfu(DFUdevices[index].id!);
  }

  Future<void> doDfu(String deviceId) async {
    print("sensor fw update started");
    print(deviceId);
    print("started");

    Future.delayed(Duration(seconds: 5), () async {
      try {
        final s = await NordicDfu().startDfu(
          deviceId,
          "$assetLocation",
          fileInAsset: false,
          enableUnsafeExperimentalButtonlessServiceInSecureDfu: true,
          onEnablingDfuMode: (deviceId) {
            print(deviceId);
          },
          onDeviceDisconnecting: (string) {
            debugPrint('deviceAddress: $string');
          },
          // onErrorHandle: (string) {
          //   debugPrint('deviceAddress: $string');
          // },
          onProgressChanged: (
            deviceAddress,
            percent,
            speed,
            avgSpeed,
            currentPart,
            partsTotal,
          ) {
            debugPrint('deviceAddress: $deviceAddress, percent: $percent');
          },
        );
        debugPrint(s);
        print("updated successfully");
        dfuRunning = false;
        DFUdevices.clear();
      } catch (e) {
        dfuRunning = false;
        debugPrint(e.toString());
      }
    });
  }

  void searchDevices() {
    BleHandler.instance.scanForDevices();

    BleHandler.instance.scanSubscription?.onData((device) {
      showDevice(device);
    });
  }

  void showDevice(DiscoveredDevice device) {
    if (device.name.startsWith('Movesense')) {
      print(device);
      showDeviceDetails(device);
    }
  }

  void showDeviceDetails(
    DiscoveredDevice device,
  ) {
    String hex = Decoder.bytesToHex(device.manufacturerData);

    if (BeaconDecoder.isBeaconResponse(hex)) {
      showLiveViewDetails(device, hex);
    } else {
      // print(device);
      // print("device is idle");
    }
  }

  void showLiveViewDetails(
    DiscoveredDevice device,
    String hex,
  ) {
    LiveViewData liveViewData = BeaconDecoder.beaconDataHandler(hex, device);
    AppDevices.instance.addknownDevice(liveViewData);

    knownDeviceStream.add(AppDevices.instance.knownDevices);
  }

  void connectDevice(DiscoveredDevice device) {
    BleHandler.instance.connectToDevice(device.id);
  }

  void updateFirmwareAction(
    DiscoveredDevice device,
  ) {
    BleHandler.instance.commander = Commander(device);

    // BleHandler.instance.commander?.responseStream.listen((value) {
    //   onResponse(value);
    // });

    BleHandler.instance.commander?.setFirmwareUpgrade();
    Future.delayed(Duration(seconds: 15), () {
      print("dfu mode");
    });
  }

  void disconnectDevice() {
    BleHandler.instance.sensorDevice = null;

    Future.delayed(const Duration(milliseconds: 300), () {
      BleHandler.instance.connectionSubscription!.cancel();
    });
  }
}

void connectDFUDevice(DiscoveredDevice device) {
  BleHandler.instance.connectToDevice(device.id);
}
