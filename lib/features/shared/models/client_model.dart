class ClientModel {
  final String id;
  final String displayName;
  final String profileImageUrl;
  final String locationName;
  final String bio;
  final List<String> currentTattoos;

  const ClientModel({
    required this.id,
    required this.displayName,
    required this.profileImageUrl,
    required this.locationName,
    required this.bio,
    required this.currentTattoos,
  });

  factory ClientModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ClientModel(
      id: id,
      displayName: data['displayName'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      locationName: data['locationName'] ?? '',
      bio: data['bio'] ?? '',
      currentTattoos: List<String>.from(data['currentTattoos'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'locationName': locationName,
      'bio': bio,
      'currentTattoos': currentTattoos,
    };
  }

ClientModel copyWith({
  String? displayName,
  String? profileImageUrl,
  String? locationName,
  String? bio,
  List<String>? currentTattoos,
}) {
  return ClientModel(
    id: id,
    displayName: displayName ?? this.displayName,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    locationName: locationName ?? this.locationName,
    bio: bio ?? this.bio,
    currentTattoos: currentTattoos ?? this.currentTattoos,
  );
}
}