import 'package:equatable/equatable.dart';
import 'package:tattoo_zona/features/shared/models/artist_model.dart';

abstract class ArtistState extends Equatable {
  final int currentTab;
  const ArtistState({this.currentTab = 0});
  @override
  List<Object?> get props => [currentTab];
}

class ArtistInitial extends ArtistState {
  const ArtistInitial() : super(currentTab: 0);
}

class ArtistLoading extends ArtistState {
  const ArtistLoading({super.currentTab});
}

class ArtistLoaded extends ArtistState {
  final ArtistModel artist;

  const ArtistLoaded({
    required this.artist,
    super.currentTab,
  });

  @override
  List<Object?> get props => [artist, currentTab];

  ArtistLoaded copyWith({
    ArtistModel? artist,
    int? currentTab,
  }) {
    return ArtistLoaded(
      artist: artist ?? this.artist,
      currentTab: currentTab ?? this.currentTab,
    );
  }
}

class ArtistError extends ArtistState {
  final String message;
  const ArtistError({required this.message, super.currentTab});
  @override
  List<Object?> get props => [message, currentTab];
}