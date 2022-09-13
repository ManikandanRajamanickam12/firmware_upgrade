

import 'package:firmware/modules/bloc/sensor_bloc.dart';
import 'package:flutter/material.dart';

class InternetFailed extends StatelessWidget {
  const InternetFailed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 600,
      child: Column(
        children: [
          Center(child: Text("error in network"),),
          ElevatedButton(onPressed: (){


            SensorBloc.instance.add(SensorSearchEvent());
          }, child: Text("Go to Home"))
        ],
      )
    );
  }
}