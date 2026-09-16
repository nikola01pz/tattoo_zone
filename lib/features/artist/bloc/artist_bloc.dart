import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tattoo_zona/features/artist/data/artist_repository.dart';
import 'artist_event.dart';
import 'artist_state.dart';

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  final ArtistRepository _repository;

  ArtistBloc({ArtistRepository? repository})
      : _repository = repository ?? ArtistRepository(),
        super(const ArtistInitial()) {
    on<ArtistTabChanged>(_onTabChanged);
    on<LoadArtistData>(_onLoadArtistData);
    on<UpdateArtistData>(_onUpdateArtistData);

    add(LoadArtistData());
  }

  void _onTabChanged(
    ArtistTabChanged event,
    Emitter<ArtistState> emit,
  ) {
    if (state is ArtistLoaded) {
      emit((state as ArtistLoaded).copyWith(currentTab: event.tabIndex));
    } else {
      emit(ArtistLoading(currentTab: event.tabIndex));
    }
  }

  Future<void> _onLoadArtistData(
    LoadArtistData event,
    Emitter<ArtistState> emit,
  ) async {
    final currentTab = state.currentTab;
    emit(ArtistLoading(currentTab: currentTab));
    try {
      final artist = await _repository.getArtist();
      emit(ArtistLoaded(
        artist: artist,
        currentTab: currentTab,
      ));
    } catch (e) {
      emit(const ArtistError(message: 'Failed to load artist data.'));
    }
  }

  Future<void> _onUpdateArtistData(
  UpdateArtistData event,
  Emitter<ArtistState> emit,
) async {
  try {
    await _repository.updateArtist(event.artist);
    emit(ArtistLoaded(
      artist: event.artist,
      currentTab: state.currentTab,
    ));
  } catch (e) {
    emit(const ArtistError(message: 'Failed to save profile.'));
  }
}

  
}