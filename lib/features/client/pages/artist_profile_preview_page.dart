import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tattoo_zona/components/my_button.dart';
import 'package:tattoo_zona/features/chat/bloc/chat_bloc.dart';
import 'package:tattoo_zona/features/chat/bloc/chat_event.dart';
import 'package:tattoo_zona/features/chat/bloc/chat_state.dart';
import 'package:tattoo_zona/features/chat/pages/chat_page.dart';
import 'package:tattoo_zona/features/chat/repository/chat_repository.dart';
import 'package:tattoo_zona/features/client/bloc/client_bloc.dart';
import 'package:tattoo_zona/features/client/bloc/client_state.dart';
import 'package:tattoo_zona/features/shared/models/artist_model.dart';

class ArtistProfilePreviewPage extends StatelessWidget {
  final ArtistModel artist;

  const ArtistProfilePreviewPage({
    super.key,
    required this.artist,
  });

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
    final currentUser = FirebaseAuth.instance.currentUser!;

    return BlocProvider(
      create: (_) => ChatBloc(chatRepository: ChatRepository()),
      child: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ConversationCreated) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  conversationId: state.conversationId,
                  otherPersonName: artist.displayName,
                ),
              ),
            );
          }

          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              artist.displayName.isNotEmpty
                  ? artist.displayName
                  : 'Artist profile',
            ),
          ),
          body: BlocBuilder<ClientBloc, ClientState>(
            builder: (context, clientState) {
              if (clientState is! ClientLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final client = clientState.client;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
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
                                  : 'Unknown artist',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (artist.locationName.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      artist.locationName,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${artist.rating.toStringAsFixed(1)} (${artist.reviewCount})',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
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
                  Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<ChatBloc, ChatState>(
                          builder: (context, chatState) {
                            final isLoading = chatState is ChatLoading;

                            return MyButton(
                              text: isLoading ? 'Opening...' : 'Message',
                              margin: EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onTap: isLoading
                                  ? () {}
                                  : () {
                                      context.read<ChatBloc>().add(
                                            CreateConversation(
                                              artistId: artist.id,
                                              clientId: currentUser.uid,
                                              artistName: artist.displayName,
                                              clientName: client.displayName,
                                            ),
                                          );
                                    },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MyButton(
                          text: 'Book appointment',
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Booking flow comes next'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (artist.styles.isNotEmpty) ...[
                    const Text(
                      'Styles',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                        style: const TextStyle(
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (artist.bio.isNotEmpty) ...[
                    const Text(
                      'Bio',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                        style: const TextStyle(
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                  const Text(
                    'Portfolio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                          context,
                          artist.portfolioImages[index],
                        ),
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
          ),
        ),
      ),
    );
  }
}