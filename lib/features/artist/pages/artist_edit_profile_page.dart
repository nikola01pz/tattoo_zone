import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tattoo_zona/components/my_button.dart';
import 'package:tattoo_zona/features/artist/bloc/artist_bloc.dart';
import 'package:tattoo_zona/features/artist/bloc/artist_event.dart';
import 'package:tattoo_zona/features/artist/bloc/artist_state.dart';
import 'package:tattoo_zona/features/shared/models/artist_model.dart';
import 'package:tattoo_zona/features/artist/data/artist_repository.dart';
import 'package:tattoo_zona/features/shared/services/storage_service.dart';

class ArtistEditProfilePage extends StatefulWidget {
  const ArtistEditProfilePage({super.key});

  @override
  State<ArtistEditProfilePage> createState() => _ArtistEditProfilePageState();
}

class _ArtistEditProfilePageState extends State<ArtistEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _storage = StorageService();
  final _repository = ArtistRepository();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;

  late ArtistModel _artist;
  File? _newProfileImage;
  final List<File> _newTattooImages = [];
  bool _isSaving = false;

  final List<String> _availableStyles = [
    'traditional',
    'neo-traditional',
    'realism',
    'watercolor',
    'blackwork',
    'geometric',
    'japanese',
    'tribal',
    'minimalist',
    'illustrative',
    'dotwork',
    'surrealism',
  ];
  late List<String> _selectedStyles;

  @override
  void initState() {
    super.initState();
    final state = context.read<ArtistBloc>().state;
    if (state is ArtistLoaded) {
      _artist = state.artist;
    } else {
      _artist = ArtistModel(
        id: '',
        displayName: '',
        bio: '',
        styles: [],
        latitude: 0.0,
        longitude: 0.0,
        locationName: '',
        profileImageUrl: '',
        rating: 0.0,
        reviewCount: 0,
        portfolioImages: [],
      );
    }

    _nameController = TextEditingController(text: _artist.displayName);
    _bioController = TextEditingController(text: _artist.bio);
    _locationController = TextEditingController(text: _artist.locationName);
    _selectedStyles = List<String>.from(_artist.styles);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _toggleStyle(String style) {
    setState(() {
      if (_selectedStyles.contains(style)) {
        _selectedStyles.remove(style);
      } else {
        _selectedStyles.add(style);
      }
    });
  }

  Future<void> _verifyAddress() async {
    final address = _locationController.text.trim();
    if (address.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      final locations = await locationFromAddress(address);
      if (!mounted) return;

      if (locations.isNotEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Found: ${locations.first.latitude.toStringAsFixed(4)}, ${locations.first.longitude.toStringAsFixed(4)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Address not found. Try a more specific address.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Error resolving address.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _isSaving = true);

    try {
      final state = context.read<ArtistBloc>().state;
      if (state is! ArtistLoaded) return;

      final uid = state.artist.id;
      String profileImageUrl = _artist.profileImageUrl;
      List<String> portfolioUrls = List.from(_artist.portfolioImages);

      if (_newProfileImage != null) {
        profileImageUrl =
            await _storage.uploadProfileImage(uid, _newProfileImage!);
      }

      for (final file in _newTattooImages) {
        final url = await _storage.uploadTattooImage(uid, file);
        portfolioUrls.add(url);
      }

      double lat = _artist.latitude;
      double lng = _artist.longitude;

      final address = _locationController.text.trim();
      if (address.isNotEmpty) {
        try {
          final locations = await locationFromAddress(address);
          if (!mounted) return;

          if (locations.isNotEmpty) {
            lat = locations.first.latitude;
            lng = locations.first.longitude;
          }
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to resolve address.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      final updated = _artist.copyWith(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        locationName: address,
        styles: _selectedStyles,
        latitude: lat,
        longitude: lng,
        profileImageUrl: profileImageUrl,
        portfolioImages: portfolioUrls,
      );

      await _repository.updateArtist(updated);

      if (mounted) {
        context.read<ArtistBloc>().add(LoadArtistData());
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final file = await _storage.pickImage();
    if (file != null) {
      setState(() => _newProfileImage = file);
    }
  }

  Future<void> _pickTattooImage() async {
    final file = await _storage.pickImage();
    if (file != null) {
      setState(() => _newTattooImages.add(file));
    }
  }

  Future<void> _deleteExistingTattoo(String url) async {
    await _storage.deleteImage(url);
    final updated = _artist.copyWith(
      portfolioImages: _artist.portfolioImages.where((u) => u != url).toList(),
    );
    await _repository.updateArtist(updated);
    if (mounted) {
      context.read<ArtistBloc>().add(LoadArtistData());
    }
    setState(() => _artist = _artist.copyWith(
          portfolioImages:
              _artist.portfolioImages.where((u) => u != url).toList(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // PROFILNA SLIKA
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundImage: _newProfileImage != null
                          ? FileImage(_newProfileImage!)
                          : (_artist.profileImageUrl.isNotEmpty
                              ? NetworkImage(_artist.profileImageUrl)
                              : null) as ImageProvider?,
                      child: (_newProfileImage == null &&
                              _artist.profileImageUrl.isEmpty)
                          ? const Icon(Icons.person, size: 56)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // DISPLAY NAME
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

            // LOCATION
            const Text(
              'Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter full address for map display (e.g. Vukovarska 10, Zagreb)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Vukovarska 10, Osijek, Croatia',
                      filled: true,
                      fillColor: const Color(0xFFEEEEEE),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _verifyAddress,
                  child: const Text('Verify'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // BIO
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // STYLES
            const Text(
              'Tattoo Styles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableStyles.map((style) {
                final selected = _selectedStyles.contains(style);
                return GestureDetector(
                  onTap: () => _toggleStyle(style),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.black
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? Colors.black : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      style,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // PORTRAIT
            const Text(
              'Portfolio Tattoos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount:
                  _artist.portfolioImages.length + _newTattooImages.length + 1,
              itemBuilder: (context, index) {
                if (index ==
                    _artist.portfolioImages.length +
                        _newTattooImages.length) {
                  return GestureDetector(
                    onTap: _isSaving ? null : _pickTattooImage,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.grey),
                    ),
                  );
                }

                if (index < _artist.portfolioImages.length) {
                  final url = _artist.portfolioImages[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                        ),
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

                final newIndex = index - _artist.portfolioImages.length;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _newTattooImages[newIndex],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _newTattooImages.removeAt(newIndex),
                        ),
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

            const SizedBox(height: 28),

            MyButton(
              text: 'Save Changes',
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onTap: _isSaving ? null : _save,
            ),

            if (_isSaving) ...[
              const SizedBox(height: 8),
              const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}