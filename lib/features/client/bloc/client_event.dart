import 'package:equatable/equatable.dart';

abstract class ClientEvent extends Equatable {
  const ClientEvent();
  @override
  List<Object?> get props => [];
}

class ClientTabChanged extends ClientEvent {
  final int tabIndex;
  const ClientTabChanged(this.tabIndex);
  @override
  List<Object?> get props => [tabIndex];
}

class LoadClientData extends ClientEvent {}