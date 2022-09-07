import 'dart:async';

import 'package:firmware/modules/bloc/sensor_bloc.dart';
import 'package:firmware/page/ble_handler.dart';
import 'package:firmware/page/dashboard_grid.dart';
import 'package:firmware/page/firmware_upgrade.dart';
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
                  } else if (state is SensorTestState) {
                    return Center(
                      child: Text(
                        "Connected to sensor",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is SensorUpgradeFirmwareState) {
                    return FirmwareUpgrade();
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

          ///create a screen for bluetooth powered off state
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
