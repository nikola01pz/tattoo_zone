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
  final List<String> portfolioImages;
  final double totalEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;

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
    this.portfolioImages = const [],
    this.totalEarnings = 0.0,
    this.weeklyEarnings = 0.0,
    this.monthlyEarnings = 0.0,
  });

  factory ArtistModel.fromFirestore(Map<String, dynamic> data, String id) {
    final GeoPoint? location = data['location'] as GeoPoint?;
    final earnings = data['earnings'] as Map<String, dynamic>? ?? {};

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
      portfolioImages: List<String>.from(data['portfolioImages'] ?? []),
      totalEarnings: (earnings['total'] ?? 0.0).toDouble(),
      weeklyEarnings: (earnings['weekly'] ?? 0.0).toDouble(),
      monthlyEarnings: (earnings['monthly'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'bio': bio,
      'styles': styles,
      'location': GeoPoint(latitude, longitude),
      'locationName': locationName,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'portfolioImages': portfolioImages,
      'earnings': {
        'total': totalEarnings,
        'weekly': weeklyEarnings,
        'monthly': monthlyEarnings,
      },
    };
  }

  ArtistModel copyWith({
    String? displayName,
    String? bio,
    List<String>? styles,
    double? latitude,
    double? longitude,
    String? locationName,
    String? profileImageUrl,
    double? rating,
    int? reviewCount,
    List<String>? portfolioImages,
    double? totalEarnings,
    double? weeklyEarnings,
    double? monthlyEarnings,
  }) {
    return ArtistModel(
      id: id,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      styles: styles ?? this.styles,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
    );
  }
}