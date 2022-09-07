import 'package:firmware/modules/models/live_view_data.dart';

class AppDevices {
  static final AppDevices _client = AppDevices._internal();

  factory AppDevices() {
    return _client;
  }

  AppDevices._internal() {}

  static AppDevices get instance => _client;

  Map<String, LiveViewData> knownDevices = {};

  void addknownDevice(LiveViewData model) {
    knownDevices[model.device.name] = model;
    // knownDevices[model.device.id] = model;
  }
}
