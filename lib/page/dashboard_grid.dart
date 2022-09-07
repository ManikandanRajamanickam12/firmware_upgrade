// ignore_for_file: prefer_const_constructors

import 'package:firmware/modules/bloc/sensor_bloc.dart';
import 'package:firmware/modules/models/live_view_data.dart';
import 'package:firmware/page/ble_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:rxdart/rxdart.dart';

class DashboardGrid extends StatelessWidget {
  final BehaviorSubject<Map<String, LiveViewData>?> knownDeviceStream;

  const DashboardGrid({
    Key? key,
    required this.knownDeviceStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.875,
        child: Column(
          children: [
            StreamBuilder<Map<String, LiveViewData>?>(
                stream: knownDeviceStream.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return GridView.builder(
                        itemCount: snapshot.data!.keys.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 1.49),
                        itemBuilder: (context, index) {
                          String key = snapshot.data!.keys.elementAt(index);
                          print(snapshot.data!.keys);

                          LiveViewData liveViewData = snapshot.data![key]!;
                          return Column(
                            children: [
                              Text(liveViewData.device.name),
                              ElevatedButton(
                                  onPressed: () {
                                    SensorBloc.instance.add(SensorConnectEvent(
                                        device: liveViewData.device));
                                  },
                                  child: Text("Connect"))
                            ],
                          );
                        });
                  } else {
                    return Container();
                  }
                })
          ],
        ),
      ),
    );
  }
}
