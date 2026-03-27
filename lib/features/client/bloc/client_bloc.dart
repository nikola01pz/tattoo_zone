import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tattoo_zona/features/client/data/models/client_model.dart';
import '../data/client_repository.dart';
import '../data/models/artist_model.dart';
import '../data/models/tattoo_model.dart';
import 'client_event.dart';
import 'client_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final ClientRepository _repository;

  ClientBloc({ClientRepository? repository})
      : _repository = repository ?? ClientRepository(),
        super(const ClientInitial()) {
    on<ClientTabChanged>(_onTabChanged);
    on<LoadClientData>(_onLoadClientData);
  
    add(LoadClientData());
  }

  void _onTabChanged(
    ClientTabChanged event,
    Emitter<ClientState> emit,
  ) {
    if (state is ClientLoaded) {
      emit((state as ClientLoaded).copyWith(currentTab: event.tabIndex));
    } else {
      emit(ClientLoading(currentTab: event.tabIndex));
    }
  }

Future<void> _onLoadClientData(
  LoadClientData event,
  Emitter<ClientState> emit,
) async {
  final currentTab = state.currentTab;
  emit(ClientLoading(currentTab: currentTab));
  try {
    final results = await Future.wait([
      _repository.getTattoos(),
      _repository.getArtists(),
      _repository.getClient(),
    ]);

    emit(ClientLoaded(
      currentTab: currentTab,
      tattoos: results[0] as List<TattooModel>,
      artists: results[1] as List<ArtistModel>,
      client: results[2] as ClientModel,
    ));
  } catch (e) {
    emit(const ClientError(message: 'Failed to load data.'));
  }
}
}