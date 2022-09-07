part of 'sensor_bloc.dart';

abstract class SensorEvent extends Equatable {
  const SensorEvent();
}

class SensorSearchEvent extends SensorEvent {
  const SensorSearchEvent();

  @override
  List<Object> get props => [];
}

class SensorLiveViewEvent extends SensorEvent {
  // final ValueStream<Map<String, LiveViewData>?> liveMetricsStream;

  const SensorLiveViewEvent();

  @override
  List<Object> get props => [];
}

class SensorConnectEvent extends SensorEvent {
  final DiscoveredDevice device;
  const SensorConnectEvent({required this.device});

  @override
  List<Object> get props => [device];
}

class SensorResponseEvent extends SensorEvent {
  final DecodedResponse response;

  const SensorResponseEvent(
    this.response,
  );

  @override
  List<Object> get props => [response];
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
