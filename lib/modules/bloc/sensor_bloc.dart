import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firmware/modules/models/dfu.dart';
import 'package:firmware/modules/models/download_success.dart';
import 'package:firmware/modules/models/live_view_data.dart';
import 'package:firmware/modules/models/models.dart';
import 'package:firmware/modules/models/network_connectivity.dart';
import 'package:firmware/modules/models/read_file.dart';
import 'package:firmware/modules/models/sensor_details.dart';
import 'package:firmware/modules/models/sensor_info_data.dart';
import 'package:firmware/modules/models/upgrade_process.dart';
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
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../page/constants.dart';
import '../models/download_file.dart';
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

  final BehaviorSubject<DownloadFile> downloadFileStream =
      BehaviorSubject.seeded(DownloadFile(
    zipDownloaded: false,
    mdFileDownloded: false,
  ));

  final BehaviorSubject<DownloadSuccess> downloadSuccessStream =
      BehaviorSubject.seeded(DownloadSuccess(
    zipDownloadedSuccess: false,
    mdFileDownlodedSuccess: false,
  ));

  final BehaviorSubject<UpgradeProcess> upgradeProcessStream =
      BehaviorSubject.seeded(UpgradeProcess(
          devicesId: "0:0:0:0",
          percent: 0,
          speed: 0.0,
          avgSpeed: 0.0,
          currentPart: 0,
          totalPart: 0));

  final BehaviorSubject<ReadFile> readFileStream =
      BehaviorSubject.seeded(ReadFile(readMdFile: false));

  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  bool dfuRunning = true;
  List<DFU> dfuDevices = [];
  String assetLocation = "";
  String? url;
  String? mdUrl;

  String? path;
  String? mdPath;

  String? dir;
  String localZipFileName = 'confw.zip';
  String localMdFileName = "releasenotes.txt";

  bool zip = false;
  bool mdFile = false;

  bool readMdFile = false;

  bool zipSuccess = false;
  bool mdSuccess = false;

  String? responseText;

  String? localSensorVersion;

  int max = 0;
  int index = 0;

  StreamSubscription? streamOne;
  StreamSubscription? streamTwo;
  StreamSubscription? streamThree;

  Map source = {ConnectivityResult.none: false};
  final NetworkConnectivity networkConnectivity = NetworkConnectivity.instance;

  SensorBloc._internal() : super(SensorInitialState()) {
    on<SensorSearchEvent>((event, emit) async {
      searchDevices();
      emit(SensorLiveViewState());
    });
    on<SensorLoadingEvent>((event, emit) async {
      emit(const SensorLoadingState());
    });

    on<SensorConnectEvent>((event, emit) async {
      BleHandler.instance.scanSubscription?.cancel();

      connectDevice(event.device);

      BleHandler.instance.connectionSubscription!.onData((updates) async {
        /* SENSOR CONNECTED */

        if (updates.connectionState == DeviceConnectionState.connected) {
          BleHandler.instance.sensorDevice = event.device;
          // add(SensorUpgradeHelperEvent());

          add(SensorInfoResponseHelperEvent(event.device));
          print("emmit");
        } else if (updates.connectionState ==
            DeviceConnectionState.connecting) {
          add(SensorConnectingEvent());
        } else if (updates.connectionState ==
            DeviceConnectionState.disconnected) {
          add(SensorDisconnectEvent());
        }
      });

      BleHandler.instance.connectionSubscription!.onError((dynamic error) {
        log('>> ${error.toString()}');
      });
    });
    on<SensorBLEOffEvent>((event, emit) async {
      emit(const SensorBLEOffState());
    });
    on<SensorConnectingEvent>((event, emit) async {
      emit(const SensorConnectingState());
    });
    on<SensorDisconnectEvent>((event, emit) async {
      emit(const SensorDisconnectState());
    });
    on<SensorInfoResponseHelperEvent>((event, emit) async {
      emit(const SensorGetInfoResponseState());
      sensorResponseDetails(event.device, (response) {
        add(SensorGetInfoResponseEvent(event.device, response));
      });
    });

    on<SensorGetInfoResponseEvent>((event, emit) async {
      if (event.response is InfoResponse) {
        var infoResponse = event.response as InfoResponse;
        SensorInfoData sensorInfoData = handleInfoResponse(infoResponse);

        BleHandler.instance.sensorInfoData = sensorInfoData;
        SharedPreferences data = await prefs;

        data.setString(
            "current_version", sensorInfoData.sensorDetails.firmwareVersion);
        print("${data.getString("current_version")} cache ");
      }
    });

    on<SensorUpgradeHelperEvent>((event, emit) {
      networkConnectivity.initialise();
      networkConnectivity.myStream.listen((sourceStream) {
        source = sourceStream;
        print(source.values.toList()[0]);
        if (source.values.toList()[0]) {
          add(const SensorStartUpgradeEvent());
        } else {
          add(SensorInternetTestEvent());
        }
      });
    });
    on<SensorStartUpgradeEvent>((event, emit) {
      emit(const SensorUpgradeInitiateState());
    });
    on<SensorInternetTestEvent>((event, emit) {
      emit(const SensorInternetConnectionFailureState());
    });

    on<SensorCheckForUpdatesEvent>((event, emit) async {
      networkConnectivity.initialise();
      networkConnectivity.myStream.listen((sourceStream) {
        source = sourceStream;
        print(source.values.toList()[0]);
        if (source.values.toList()[0] == false) {
          add(const SensorInternetTestEvent());
        } else {
          event.ref.getDownloadURL().then((value) {
            url = value.toString();
            dir = event._dir;
            path = '$dir/$localZipFileName';
            zip = true;
            downloadFileStream.add(DownloadFile(
              zipDownloaded: zip,
              mdFileDownloded: mdFile,
            ));
          });
          event.mdRef.getDownloadURL().then((value) {
            mdUrl = value.toString();
            dir = event._dir;
            mdPath = '$dir/$localMdFileName';
            mdFile = true;
            downloadFileStream.add(DownloadFile(
              zipDownloaded: zip,
              mdFileDownloded: mdFile,
            ));
          });

          streamOne = downloadFileStream.listen((value) {
            if (value.zipDownloaded && value.mdFileDownloded) {
              add(SensorDownloadFirmwareFileEvent(url!, localZipFileName));
            } else {
              add(const SensorLoadingEvent());
            }
          });
        }
      });
    });

    on<SensorDownloadFirmwareFileEvent>((event, emit) {
      downloadzipFile().then((value) {
        zipSuccess = true;
        downloadSuccessStream.add(DownloadSuccess(
          zipDownloadedSuccess: zipSuccess,
          mdFileDownlodedSuccess: mdSuccess,
        ));
      });

      downloadMdFile().then((value) {
        mdSuccess = true;
        downloadSuccessStream.add(DownloadSuccess(
          zipDownloadedSuccess: zipSuccess,
          mdFileDownlodedSuccess: mdSuccess,
        ));
      });

      streamTwo = downloadSuccessStream.listen((value) {
        if (value.zipDownloadedSuccess && value.mdFileDownlodedSuccess) {
          readFile().then((value) {
            readMdFile = true;
            responseText = value;
            readFileStream.add(ReadFile(readMdFile: readMdFile));
          });
        }
      });

      streamThree = readFileStream.listen((value) async {
        if (value.readMdFile) {
          SharedPreferences data = await prefs;
          localSensorVersion = data.getString("current_version");
          if (responseText!.split(" ")[1] != localSensorVersion) {
            data.setString("current_version", responseText!.split(" ")[1]);
            add(SensorUpgradeFirmwareEvent(path!));
          } else {
            streamOne!.cancel();
            streamTwo!.cancel();
            streamThree!.cancel();

            disconnectDevice();
            add(const SensorAlreadyUpToDateEvent());
          }
        } else {
          add(const SensorLoadingEvent());
        }
      });
    });

    on<SensorUpgradeFirmwareEvent>((event, emit) async {
      BleHandler.instance.commander =
          Commander(BleHandler.instance.sensorDevice);
      assetLocation = event.asset;
      BleHandler.instance.commander?.setFirmwareUpgrade();
      Future.delayed(const Duration(seconds: 2), () {
        doAction();
      });
    });
    on<SensorUpgradingFirmwareEvent>((event, emit) async {
      emit(const SensorUpgradingFirmwareState());
    });
    on<SensorAlreadyUpToDateEvent>((event, emit) async {
      emit(const SensorAlreadyUpToDateState("Already up to data"));
    });

    on<SensorUpgradeSuccessEvent>((event, emit) async {
      emit(const SensorUpgradeSuccessState());
    });
    on<SensorUpgradeFailureEvent>((event, emit) async {
      emit(const SensorUpgradeFailureState());
    });
  }

  void sensorResponseDetails(
      DiscoveredDevice device, Function(DecodedResponse) onResponse) {
    BleHandler.instance.commander = Commander(device);

    BleHandler.instance.commander?.responseStream.listen((value) {
      onResponse(value);
    });

    BleHandler.instance.commander?.getSensorInfo();
  }

  SensorInfoData handleInfoResponse(InfoResponse response) {
    SensorDetails sensorDetails = SensorDetails.fromInfoResponse(response);

    return SensorInfoData(
        sensorDetails: sensorDetails, device: BleHandler.instance.sensorDevice);
  }

  Future<String> readFile() async {
    try {
      final file = File('$dir/$localMdFileName');

      // Read the file
      responseText = await file.readAsString();
      // print(responseText);

      return responseText!;
    } catch (e) {
      // If encountering an error, return 0
      return "error $e";
    }
  }

  Future<File> downloadzipFile() async {
    var req = await http.Client().get(Uri.parse(url!));
    var file = File('$dir/$localZipFileName');

    return file.writeAsBytes(req.bodyBytes);
  }

  Future<File> downloadMdFile() async {
    var req = await http.Client().get(Uri.parse(mdUrl!));
    var file = File('$dir/$localMdFileName');

    return file.writeAsBytes(req.bodyBytes);
  }

  void doAction() {
    disconnectDevice();

    print("upgrade start");
    BleHandler.instance.scanForDevices();
    BleHandler.instance.scanSubscription?.onData((device) {
      if (device.name.startsWith("Dfu")) {
        dfuDevices
            .add(DFU(name: device.name, id: device.id, rssi: device.rssi));
        print(dfuDevices.length);

        connectDFUDevice(device);

        Future.delayed(const Duration(seconds: 4), () {
          upgradeFirmware();
        });
      } else
        print("not connected to dfu ${device.name}");
    });
    // });
  }

  upgradeFirmware() {
    max = dfuDevices[0].rssi!;
    index = 0;
    for (int i = 0; i < dfuDevices.length; i++) {
      if (dfuDevices[i].rssi! > max) {
        max = dfuDevices[i].rssi!;
        index = i;
      } else {
        max = dfuDevices[0].rssi!;
      }
    }
    print(max);
    print(index);
    print(dfuDevices.toString());
    doDfu(dfuDevices[index].id!);
  }

  Future<void> doDfu(String deviceId) async {
    print("sensor fw update started");
    print(deviceId);
    print("started");
    SensorBloc.instance.add(const SensorUpgradingFirmwareEvent());
    Future.delayed(const Duration(seconds: 5), () async {
      try {
        final s = await NordicDfu().startDfu(
          deviceId,
          assetLocation,
          fileInAsset: false,
          enableUnsafeExperimentalButtonlessServiceInSecureDfu: true,
          onDeviceDisconnecting: (string) {
            debugPrint('deviceAddress: $string');
          },
          onProgressChanged: (
            deviceAddress,
            percent,
            speed,
            avgSpeed,
            currentPart,
            partsTotal,
          ) {
            debugPrint(
                'deviceAddress: $deviceAddress, percent: $percent , currentPart: $currentPart , totalPArt:$partsTotal');
            upgradeProcessStream.add(UpgradeProcess(
                devicesId: deviceAddress,
                percent: percent,
                speed: speed,
                avgSpeed: avgSpeed,
                currentPart: currentPart,
                totalPart: partsTotal));
            if (percent == 100) {
              dfuRunning = false;
            }
          },
        );

        print("updated successfully");

        dfuDevices.clear();
        if (!dfuRunning) {
          disconnectDFUDevice();
        } else {
          SensorBloc.instance.add(const SensorUpgradeFailureEvent());
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  void searchDevices() {
    BleHandler.instance.scanForDevices();
    BleHandler.instance.scanSubscription?.onData((device) {
      showDevice(device);
      print(device);
    });
  }

  void showDevice(DiscoveredDevice device) {
    if (device.name.startsWith('Movesense')) {
      showDeviceDetails(device);
    }
  }

  void showDeviceDetails(DiscoveredDevice device) {
    String hex = Decoder.bytesToHex(device.manufacturerData);

    if (BeaconDecoder.isBeaconResponse(hex)) {
      showLiveViewDetails(device, hex);
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
    BleHandler.instance.commander?.setFirmwareUpgrade();
    print("dfu mode");
  }

  void disconnectDevice() {
    BleHandler.instance.sensorDevice = null;

    Future.delayed(const Duration(seconds: 1), () {
      BleHandler.instance.connectionSubscription!.cancel();
    });

    resetDevice();
  }

  void connectDFUDevice(DiscoveredDevice device) {
    BleHandler.instance.connectToDevice(device.id);
  }

  void resetDevice() {
    disposeStream();
  }

  void disposeStream() {
    knownDeviceStream.add(null);
  }

  void disconnectDFUDevice() {
    NordicDfu().abortDfu();
    BleHandler.instance.commander!.cancelDataSubscription();
    streamOne!.cancel();
    streamTwo!.cancel();
    streamThree!.cancel();
    Future.delayed(const Duration(seconds: 1), () {
      BleHandler.instance.commander!.cancelResponseStream();
      BleHandler.instance.connectionSubscription!.cancel();
      BleHandler.instance.commander = null;
    });
    Future.delayed(const Duration(seconds: 5), () {
      SensorBloc.instance.add(const SensorUpgradeSuccessEvent());
    });
  }
}
