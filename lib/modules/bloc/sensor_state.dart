part of 'sensor_bloc.dart';

abstract class SensorState extends Equatable {
  const SensorState();
}

class SensorInitialState extends SensorState {
  @override
  List<Object> get props => [];
}

class SensorBLEOffState extends SensorState {
  const SensorBLEOffState();

  @override
  List<Object> get props => [];
}
class SensorLiveViewState extends SensorState {
  @override
  List<Object> get props => [];
}

class SensorLoadingState extends SensorState {
  const SensorLoadingState();

  @override
  List<Object> get props => [];
}

class SensorConnectingState extends SensorState {
  const SensorConnectingState();

  @override
  List<Object> get props => [];
}
class SensorDisconnectState extends SensorState {
  const SensorDisconnectState();

  @override
  List<Object> get props => [];
}

class SensorGetInfoResponseState extends SensorState {
  const SensorGetInfoResponseState();

  @override
  List<Object> get props => [];
}

class SensorInternetConnectionFailureState extends SensorState {
  const SensorInternetConnectionFailureState();

  @override
  List<Object> get props => [];
}

class SensorUpgradeInitiateState extends SensorState {
  const SensorUpgradeInitiateState();

  @override
  List<Object> get props => [];
}

class SensorCheckForUpdatesState extends SensorState {
  const SensorCheckForUpdatesState();

  @override
  List<Object> get props => [];
}

class SensorAlreadyUpToDateState extends SensorState {
  final String textResponse;
  const SensorAlreadyUpToDateState(this.textResponse);

  @override
  List<Object> get props => [textResponse];
}

class SensorUpgradeSuccessState extends SensorState {
  const SensorUpgradeSuccessState();

  @override
  List<Object> get props => [];
}
class SensorUpgradeFailureState extends SensorState {
  const SensorUpgradeFailureState();

  @override
  List<Object> get props => [];
}

class SensorUpgradingFirmwareState extends SensorState {
  const SensorUpgradingFirmwareState();

  @override
  List<Object> get props => [];
}
