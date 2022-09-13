import 'dart:io';
import 'package:download_assets/download_assets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firmware/modules/bloc/sensor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FirmwareUpgrade extends StatefulWidget {
  const FirmwareUpgrade({Key? key}) : super(key: key);

  @override
  State<FirmwareUpgrade> createState() => _FirmwareUpgradeState();
}

class _FirmwareUpgradeState extends State<FirmwareUpgrade> {
  String? url;
  String assetLocation = "";

  Future<ListResult>? futureFiles;
  bool? _downloading;
  String? _dir;
  String _localZipFileName = 'confw.zip';
  String? path;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _downloading = false;
    _initDir();
    futureFiles = FirebaseStorage.instance.ref("/firmware").listAll();
  }

  // Initialize the directory to get the Device's Documents directory //
  _initDir() async {
    if (null == _dir) {
      _dir = (await getApplicationDocumentsDirectory()).path;
    }
  }

  // // Download the ZIP file using the HTTP library //
  // Future<File> _downloadzipFile(String url, String fileName) async {
  //   var req = await http.Client().get(Uri.parse(url));
  //   var file = File('$_dir/$fileName');
  //   print(file);
  //   return file.writeAsBytes(req.bodyBytes);
  // }
  //
  // Future downloadFile(Reference ref) async {
  //   print(ref);
  //   await ref.getDownloadURL().then((value) {
  //     setState(() {
  //       url = value.toString();
  //       path = '$_dir/$_localZipFileName';
  //     });
  //   });
  //   print("$url from firebase");
  //   print("$path from local");
  //   if (url != "") {
  //     Future.delayed(Duration(seconds: 6), () {
  //       print("$url for zip");
  //       _downloadzipFile(url!, _localZipFileName);
  //     });
  //     print("getting path");
  //
  //     Future.delayed(Duration(seconds: 3), () {
  //       if (path != null)
  //         callEvent();
  //       else
  //         print("error in the path");
  //     });
  //   } else {
  //     print("url not get from firebase");
  //   }
  // }
  //
  // void callEvent() {
  //   SensorBloc.instance.add(SensorUpgradeFirmwareEvent(path!));
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        child: Column(
          children: [
            FutureBuilder<ListResult>(
              future: futureFiles,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final files = snapshot.data!.items;
                  return Container(
                    width: 600,
                    height: 100,
                    child: ListView.builder(
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          final file = files[0];
                          final mdFile = files[1];

                          return IconButton(
                            icon: Icon(Icons.download),
                            onPressed: () {
                              print("pressed");
                              // downloadFile(file);
                              SensorBloc.instance.add(
                                  SensorCheckForUpdatesEvent(
                                      file, mdFile,_dir!));
                              print("zip process done");
                            },
                          );
                        }),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error occured"));
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ));
  }
}
