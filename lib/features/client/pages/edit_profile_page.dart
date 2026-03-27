import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';
import '../data/models/client_model.dart';
import '../data/client_repository.dart';
import '../data/storage_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _storage = StorageService();
  final _repository = ClientRepository();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;

  late ClientModel _client;
  File? _newProfileImage;
  final List<File> _newTattooImages = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _client = (context.read<ClientBloc>().state as ClientLoaded).client;
    _nameController = TextEditingController(text: _client.displayName);
    _bioController = TextEditingController(text: _client.bio);
    _locationController = TextEditingController(text: _client.locationName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      String profileImageUrl = _client.profileImageUrl;
      List<String> tattooUrls = List.from(_client.currentTattoos);

      if (_newProfileImage != null) {
        profileImageUrl =
            await _storage.uploadProfileImage(uid, _newProfileImage!);
      }

      for (final file in _newTattooImages) {
        final url = await _storage.uploadTattooImage(uid, file);
        tattooUrls.add(url);
      }

      final updated = _client.copyWith(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        locationName: _locationController.text.trim(),
        profileImageUrl: profileImageUrl,
        currentTattoos: tattooUrls,
      );

      await _repository.updateClient(updated);
      
      if (mounted) {
        context.read<ClientBloc>()
          ..add(ClientTabChanged(3))
          ..add(LoadClientData());
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final file = await _storage.pickImage();
    if (file != null) setState(() => _newProfileImage = file);
  }

  Future<void> _pickTattooImage() async {
    final file = await _storage.pickImage();
    if (file != null) setState(() => _newTattooImages.add(file));
  }

  Future<void> _deleteExistingTattoo(String url) async {
    await _storage.deleteImage(url);
    final updated = _client.copyWith(
      currentTattoos: _client.currentTattoos.where((u) => u != url).toList(),
    );
    await _repository.updateClient(updated);
    if (mounted) context.read<ClientBloc>().add(LoadClientData());
    setState(() => _client = _client.copyWith(
          currentTattoos:
              _client.currentTattoos.where((u) => u != url).toList(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text('Save',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundImage: _newProfileImage != null
                          ? FileImage(_newProfileImage!)
                          : (_client.profileImageUrl.isNotEmpty
                              ? NetworkImage(_client.profileImageUrl)
                              : null) as ImageProvider?,
                      child: (_newProfileImage == null &&
                              _client.profileImageUrl.isEmpty)
                          ? const Icon(Icons.person, size: 56)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'e.g. Osijek, Croatia',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            const Text('My Tattoos',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _client.currentTattoos.length +
                  _newTattooImages.length +
                  1,
              itemBuilder: (context, index) {
                if (index ==
                    _client.currentTattoos.length +
                        _newTattooImages.length) {
                  return GestureDetector(
                    onTap: _pickTattooImage,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.grey),
                    ),
                  );
                }

                if (index < _client.currentTattoos.length) {
                  final url = _client.currentTattoos[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(url, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _deleteExistingTattoo(url),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final newIndex =
                    index - _client.currentTattoos.length;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                          _newTattooImages[newIndex],
                          fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _newTattooImages.removeAt(newIndex)),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}