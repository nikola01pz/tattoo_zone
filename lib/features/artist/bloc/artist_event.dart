import 'package:equatable/equatable.dart';
import 'package:tattoo_zona/features/shared/models/artist_model.dart';

abstract class ArtistEvent extends Equatable {
  const ArtistEvent();
  @override
  List<Object?> get props => [];
}

class ArtistTabChanged extends ArtistEvent {
  final int tabIndex;
  const ArtistTabChanged(this.tabIndex);
  @override
  List<Object?> get props => [tabIndex];
}

class UpdateArtistData extends ArtistEvent {
  final ArtistModel artist;
  const UpdateArtistData({required this.artist});
}

class LoadArtistData extends ArtistEvent {}