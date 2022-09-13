
import 'package:firmware/modules/bloc/sensor_bloc.dart';
import 'package:flutter/material.dart';

class NewFirmware extends StatefulWidget {
  const NewFirmware({Key? key}) : super(key: key);

  @override
  State<NewFirmware> createState() => _NewFirmwareState();
}

class _NewFirmwareState extends State<NewFirmware> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 3),(){
      SensorBloc.instance.add(SensorSearchEvent());
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 600,
      child: Column(
        children: [
          const Center(
            child: Text("updated new fw"),
          ),

        ],
      ),
    );
  }
}
