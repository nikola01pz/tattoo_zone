import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tattoo_zona/features/client/bloc/client_bloc.dart';
import 'package:tattoo_zona/features/client/bloc/client_state.dart';
import 'package:tattoo_zona/features/client/pages/artist_profile_preview_page.dart';
import 'package:tattoo_zona/features/shared/models/artist_model.dart';

class ArtistsPage extends StatelessWidget {
  const ArtistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (state is ClientLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ClientLoaded) {
          return Column(
            children: [
              Expanded(
                flex: 1,
                child: _ArtistsMap(artists: state.artists),
              ),
              Expanded(
                flex: 1,
                child: _ArtistsList(artists: state.artists),
              ),
            ],
          );
        }

        return const Center(child: Text('No artists found.'));
      },
    );
  }
}

class _ArtistsMap extends StatelessWidget {
  final List<ArtistModel> artists;

  const _ArtistsMap({required this.artists});

  void _openArtistProfile(BuildContext context, ArtistModel artist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ClientBloc>(),
          child: ArtistProfilePreviewPage(artist: artist),
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers(BuildContext context) {
    return artists.map((artist) {
      return Marker(
        markerId: MarkerId(artist.id),
        position: LatLng(artist.latitude, artist.longitude),
        infoWindow: InfoWindow(
          title: artist.displayName,
          snippet: artist.styles.join(', '),
          onTap: () => _openArtistProfile(context, artist),
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(45.5511, 18.6939),
        zoom: 12,
      ),
      markers: _buildMarkers(context),
    );
  }
}

class _ArtistsList extends StatelessWidget {
  final List<ArtistModel> artists;

  const _ArtistsList({required this.artists});

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) {
      return const Center(child: Text('No artists yet.'));
    }

    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        return _ArtistCard(artist: artists[index]);
      },
    );
  }
}

class _ArtistCard extends StatelessWidget {
  final ArtistModel artist;

  const _ArtistCard({required this.artist});

  void _openArtistProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ClientBloc>(),
          child: ArtistProfilePreviewPage(artist: artist),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _openArtistProfile(context),
      leading: CircleAvatar(
        backgroundImage: artist.profileImageUrl.isNotEmpty
            ? NetworkImage(artist.profileImageUrl)
            : null,
        child: artist.profileImageUrl.isEmpty
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(
        artist.displayName.isNotEmpty ? artist.displayName : 'Unknown Artist',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${artist.styles.join(', ')} • ${artist.locationName}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          Text(artist.rating.toStringAsFixed(1)),
        ],
      ),
    );
  }
}