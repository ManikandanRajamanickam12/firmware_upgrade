import 'dart:async';
import 'package:firmware/modules/bloc/sensor_bloc.dart';
import 'package:firmware/page/InternetFailure.dart';
import 'package:firmware/page/loading.dart';
import 'package:firmware/page/new_firmware.dart';
import 'package:firmware/page/sensoe_info.dart';
import 'package:firmware/page/ble_handler.dart';
import 'package:firmware/page/dashboard_grid.dart';
import 'package:firmware/page/firmware_upgrade.dart';
import 'package:firmware/page/fwupgrade_completed.dart';
import 'package:firmware/page/upgrade_failure.dart';
import 'package:firmware/page/upgrading_process.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkBleStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocBuilder<SensorBloc, SensorState>(
                bloc: SensorBloc.instance,
                builder: (context, state) {
                  /* SensorLiveViewState */

                  if (state is SensorLiveViewState) {
                    return DashboardGrid(
                      knownDeviceStream: SensorBloc.instance.knownDeviceStream,
                    );
                  } else if (state is SensorBLEOffState) {
                    return Center(
                      child: Text("Turn on the Bluetooth"),
                    );
                  } else if (state is SensorConnectingState) {
                    return Center(
                      child: Text("connecting to sensor"),
                    );
                  } else if (state is SensorDisconnectState) {
                    return Center(child: Text("Trying to connect"));
                  } else if (state is SensorLoadingState) {
                    return Loading();
                  } else if (state is SensorInternetConnectionFailureState) {
                    return InternetFailed();
                  } else if (state is SensorGetInfoResponseState) {
                    return SensorInfo();
                  } else if (state is SensorUpgradeInitiateState) {
                    return FirmwareUpgrade();
                  } else if (state is SensorUpgradingFirmwareState) {
                    return UpgradingProcess(
                        upgradeProcess:
                            SensorBloc.instance.upgradeProcessStream);
                  } else if (state is SensorAlreadyUpToDateState) {
                    String data = state.textResponse;
                    return FWUpgradeCompleted(
                      dataResponse: data,
                    );
                  } else if (state is SensorUpgradeSuccessState) {
                    return NewFirmware();
                  } else if (state is SensorUpgradeFailureState) {
                    return UpgradeFailure();
                  } else {
                    return Container();
                  }
                })
          ]),
    ));
  }

  void checkBleStatus() {
    BleHandler.instance.bleStatusListener()?.onData((status) {
      switch (status) {
        case BleStatus.ready:
          Future.delayed(const Duration(seconds: 1), () {
            SensorBloc.instance.add(const SensorSearchEvent());
          });
          break;
        case BleStatus.poweredOff:
          Future.delayed(const Duration(seconds: 1), () {
            SensorBloc.instance.add(const SensorBLEOffEvent());
          });

          break;
        case BleStatus.unknown:
          break;
        case BleStatus.unsupported:
          break;
        case BleStatus.unauthorized:
          break;
        case BleStatus.locationServicesDisabled:
          // TODO: Handle this case.
          break;
      }
    });
  }
}
