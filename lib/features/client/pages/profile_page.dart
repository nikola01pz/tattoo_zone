import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tattoo_zona/components/my_button.dart';
import 'package:tattoo_zona/features/client/pages/edit_profile_page.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (state is ClientLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is! ClientLoaded) {
          return const Center(child: Text('Error loading profile.'));
        }

        final client = state.client;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: client.profileImageUrl.isNotEmpty
                      ? NetworkImage(client.profileImageUrl)
                      : null,
                  child: client.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.displayName.isNotEmpty
                            ? client.displayName
                            : 'No name set',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (client.locationName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 2),
                            Text(
                              client.locationName,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
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
                                    value: context.read<ClientBloc>(),
                                    child: const EditProfilePage(),
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

            if (client.bio.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  client.bio,
                  style: const TextStyle(color: Colors.grey, height: 1.5),
                ),
              ),
              const SizedBox(height: 25),
            ],

            const Text(
              'My Tattoos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (client.currentTattoos.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'No tattoos added yet.',
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
                itemCount: client.currentTattoos.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => _showImagePreview(
                      context, client.currentTattoos[index]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      client.currentTattoos[index],
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