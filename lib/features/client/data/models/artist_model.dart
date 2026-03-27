import 'package:cloud_firestore/cloud_firestore.dart';

class ArtistModel {
  final String id;
  final String displayName;
  final String bio;
  final List<String> styles;
  final double latitude;
  final double longitude;
  final String locationName;
  final String profileImageUrl;
  final double rating;
  final int reviewCount;

  const ArtistModel({
    required this.id,
    required this.displayName,
    required this.bio,
    required this.styles,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.profileImageUrl,
    required this.rating,
    required this.reviewCount,
  });

  factory ArtistModel.fromFirestore(Map<String, dynamic> data, String id) {
    final GeoPoint? location = data['location'] as GeoPoint?;

    return ArtistModel(
      id: id,
      displayName: data['displayName'] ?? '',
      bio: data['bio'] ?? '',
      styles: List<String>.from(data['styles'] ?? []),
      latitude: location?.latitude ?? 45.5511,
      longitude: location?.longitude ?? 18.6939,
      locationName: data['locationName'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
    );
  }
}