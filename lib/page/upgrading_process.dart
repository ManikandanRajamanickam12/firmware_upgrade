import 'package:firmware/modules/models/upgrade_process.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:rxdart/rxdart.dart';

class UpgradingProcess extends StatelessWidget {
  final BehaviorSubject<UpgradeProcess> upgradeProcess;

  UpgradingProcess({Key? key, required this.upgradeProcess}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 600,
      child: StreamBuilder<UpgradeProcess>(
          stream: upgradeProcess,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LinearPercentIndicator(
                    lineHeight: 25,
                    center: Text(
                      "${snapshot.data!.percent.toString()} %",
                      style: TextStyle(color: Colors.black),
                    ),
                    percent: snapshot.data!.percent / 100,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                    barRadius: Radius.circular(18),
                  ),
                  SizedBox(height: 25),
                  Text(" Device_Address - ${snapshot.data!.devicesId}"),
                  Text(" Percentage - ${snapshot.data!.percent.toString()}"),
                  Text(" Speed - ${snapshot.data!.speed.toString()}"),
                  Text(" AvgSpeed - ${snapshot.data!.avgSpeed.toString()}"),
                  Text(" Current_Part - ${snapshot.data!.currentPart.toString()}"),
                  Text(" Parts_Total - ${snapshot.data!.totalPart.toString()}"),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
