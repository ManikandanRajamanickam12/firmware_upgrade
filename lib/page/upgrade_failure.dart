
import 'package:firmware/modules/bloc/sensor_bloc.dart';
import 'package:flutter/material.dart';

class UpgradeFailure extends StatelessWidget {
  const UpgradeFailure({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(width: 600,height: 500,
    child: Column(children: [
      Text("Error Ocurred in firware Upgrade"),
      ElevatedButton(onPressed: (){
        SensorBloc.instance.add(SensorSearchEvent());
      }, child: Text("TryAgain"))
    ],),);
  }
}
