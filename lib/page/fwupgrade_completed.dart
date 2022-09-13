
import 'package:firmware/modules/bloc/sensor_bloc.dart';
import 'package:flutter/material.dart';

class FWUpgradeCompleted extends StatefulWidget {

   FWUpgradeCompleted({Key? key,required this.dataResponse}) : super(key: key);
String dataResponse;
  @override
  State<FWUpgradeCompleted> createState() => _FWUpgradeCompletedState();
}

class _FWUpgradeCompletedState extends State<FWUpgradeCompleted> {
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
    return Center(child: Text(widget.dataResponse),);
  }
}
