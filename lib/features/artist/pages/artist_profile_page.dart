import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tattoo_zona/features/artist/bloc/artist_bloc.dart';
import 'package:tattoo_zona/features/artist/bloc/artist_state.dart';
import 'package:tattoo_zona/features/artist/pages/artist_edit_profile_page.dart';
import 'package:tattoo_zona/features/auth/bloc/auth_bloc.dart';
import 'package:tattoo_zona/features/auth/bloc/auth_event.dart';
import 'package:tattoo_zona/components/my_button.dart';

class ArtistProfilePage extends StatelessWidget {
  const ArtistProfilePage({super.key});

  void _showImagePreview(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.network(url),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistBloc, ArtistState>(
      builder: (context, state) {
        if (state is ArtistLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is! ArtistLoaded) {
          return const Center(child: Text('Error loading profile.'));
        }

        final artist = state.artist;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // --- Header ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: artist.profileImageUrl.isNotEmpty
                      ? NetworkImage(artist.profileImageUrl)
                      : null,
                  child: artist.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artist.displayName.isNotEmpty
                            ? artist.displayName
                            : 'No name set',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (artist.locationName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 2),
                            Text(
                              artist.locationName,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            '${artist.rating.toStringAsFixed(1)} (${artist.reviewCount})',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: MyButton(
                              text: 'Edit',
                              margin: EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<ArtistBloc>(),
                                    child: const ArtistEditProfilePage(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MyButton(
                              text: 'Logout',
                              margin: EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onTap: () => context
                                  .read<AuthBloc>()
                                  .add(LogoutRequested()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- Styles --- (kao bio box u client profilu)
            if (artist.styles.isNotEmpty) ...[
              const Text(
                'Styles',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  artist.styles.join(', '),
                  style: const TextStyle(color: Colors.grey, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // --- Bio ---
            if (artist.bio.isNotEmpty) ...[
              const Text(
                'Bio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  artist.bio,
                  style: const TextStyle(color: Colors.grey, height: 1.5),
                ),
              ),
              const SizedBox(height: 25),
            ],

            // --- Portfolio ---
            const Text(
              'Portfolio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (artist.portfolioImages.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'No portfolio images yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: artist.portfolioImages.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => _showImagePreview(
                      context, artist.portfolioImages[index]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      artist.portfolioImages[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}