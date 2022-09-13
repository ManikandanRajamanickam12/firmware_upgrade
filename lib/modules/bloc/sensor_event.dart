part of 'sensor_bloc.dart';

abstract class SensorEvent extends Equatable {
  const SensorEvent();
}

class SensorSearchEvent extends SensorEvent {
  const SensorSearchEvent();

  @override
  List<Object> get props => [];
}


class SensorBLEOffEvent extends SensorEvent {
  const SensorBLEOffEvent();

  @override
  List<Object> get props => [];
}

class SensorLiveViewEvent extends SensorEvent {
  // final ValueStream<Map<String, LiveViewData>?> liveMetricsStream;

  const SensorLiveViewEvent();

  @override
  List<Object> get props => [];
}

class SensorLoadingEvent extends SensorEvent {
  const SensorLoadingEvent();

  @override
  List<Object> get props => [];
}
class SensorConnectingEvent extends SensorEvent {
  const SensorConnectingEvent();

  @override
  List<Object> get props => [];
}

class SensorDisconnectEvent extends SensorEvent {
  const SensorDisconnectEvent();

  @override
  List<Object> get props => [];
}

class SensorConnectEvent extends SensorEvent {
  final DiscoveredDevice device;
  const SensorConnectEvent({required this.device});

  @override
  List<Object> get props => [device];
}

class SensorGetInfoResponseEvent extends SensorEvent {
  final DiscoveredDevice device;
  final DecodedResponse response;
  SensorGetInfoResponseEvent(this.device, this.response);

  @override
  List<Object> get props => [device, response];
}

class SensorInfoResponseHelperEvent extends SensorEvent {
  final DiscoveredDevice device;
  const SensorInfoResponseHelperEvent(this.device);

  @override
  List<Object> get props => [];
}

class SensorUpgradeFirmwareEvent extends SensorEvent {
  final String asset;
  const SensorUpgradeFirmwareEvent(this.asset);

  @override
  List<Object> get props => [asset];
}

class SensorUpgradeHelperEvent extends SensorEvent {
  const SensorUpgradeHelperEvent();

  @override
  List<Object> get props => [];
}

class SensorCheckForUpdatesEvent extends SensorEvent {
  final Reference ref;
  final Reference mdRef;
  final String _dir;

  const SensorCheckForUpdatesEvent(
      this.ref, this.mdRef, this._dir);

  @override
  List<Object> get props => [ref,_dir];
}

class SensorDownloadFirmwareFileEvent extends SensorEvent {
  final String url;
  final String zipFile;

  const SensorDownloadFirmwareFileEvent(this.url, this.zipFile);

  @override
  List<Object> get props => [url, zipFile];
}

class SensorUpgradingFirmwareEvent extends SensorEvent {
  const SensorUpgradingFirmwareEvent();

  @override
  List<Object> get props => [];
}
class SensorInternetTestEvent extends SensorEvent {
  const SensorInternetTestEvent();

  @override
  List<Object> get props => [];
}
class SensorStartUpgradeEvent extends SensorEvent {
  const SensorStartUpgradeEvent();

  @override
  List<Object> get props => [];
}
class SensorUpgradeSuccessEvent extends SensorEvent {
  const SensorUpgradeSuccessEvent();

  @override
  List<Object> get props => [];
}
class SensorUpgradeFailureEvent extends SensorEvent {
  const SensorUpgradeFailureEvent();

  @override
  List<Object> get props => [];
}

class SensorAlreadyUpToDateEvent extends SensorEvent {
  const SensorAlreadyUpToDateEvent();

  @override
  List<Object> get props => [];
}

class SensorFileResponseEvent extends SensorEvent {
  const SensorFileResponseEvent();

  @override
  List<Object> get props => [];
}
