import 'package:equatable/equatable.dart';
import '../data/models/tattoo_model.dart';
import '../data/models/artist_model.dart';
import '../data/models/client_model.dart';

abstract class ClientState extends Equatable {
  final int currentTab;
  const ClientState({this.currentTab = 0});
  @override
  List<Object?> get props => [currentTab];
}

class ClientInitial extends ClientState {
  const ClientInitial() : super(currentTab: 0);
}

class ClientLoading extends ClientState {
  const ClientLoading({super.currentTab});
}

class ClientLoaded extends ClientState {
  final List<TattooModel> tattoos;
  final List<ArtistModel> artists;
  final ClientModel client;

  const ClientLoaded({
    required this.tattoos,
    required this.artists,
    required this.client,
    super.currentTab,
  });

  @override
  List<Object?> get props => [tattoos, artists, client, currentTab];

  ClientLoaded copyWith({
    List<TattooModel>? tattoos,
    List<ArtistModel>? artists,
    ClientModel? client,
    int? currentTab,
  }) {
    return ClientLoaded(
      tattoos: tattoos ?? this.tattoos,
      artists: artists ?? this.artists,
      client: client ?? this.client,
      currentTab: currentTab ?? this.currentTab,
    );
  }
}

class ClientError extends ClientState {
  final String message;
  const ClientError({required this.message, super.currentTab});
  @override
  List<Object?> get props => [message, currentTab];
}