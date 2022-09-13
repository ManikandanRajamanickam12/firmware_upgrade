import 'package:firmware/modules/bloc/sensor_bloc.dart';
import 'package:flutter/material.dart';

class SensorInfo extends StatefulWidget {
  const SensorInfo({Key? key}) : super(key: key);

  @override
  State<SensorInfo> createState() => _SensorInfoState();
}

class _SensorInfoState extends State<SensorInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 800,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("info response"),
            ElevatedButton(
                onPressed: () {
                  SensorBloc.instance.add(SensorUpgradeHelperEvent());
                },
                child: Text("Get Info"))
          ],
        ));
  }
}
