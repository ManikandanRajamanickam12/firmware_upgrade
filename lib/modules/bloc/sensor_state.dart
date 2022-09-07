part of 'sensor_bloc.dart';

abstract class SensorState extends Equatable {
  const SensorState();
}

class SensorInitialState extends SensorState {
  @override
  List<Object> get props => [];
}

class SensorLiveViewState extends SensorState {
  @override
  List<Object> get props => [];
}

class SensorLoadingState extends SensorState {
  final String message;

  const SensorLoadingState({required this.message});

  @override
  List<Object> get props => [message];
}

class SensorTestState extends SensorState {
  const SensorTestState();

  @override
  List<Object> get props => [];
}

class SensorUpgradeFirmwareState extends SensorState {
  const SensorUpgradeFirmwareState();

  @override
  List<Object> get props => [];
}
