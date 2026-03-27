class TattooModel {
  final String id;
  final String artistEmail;
  final String artistName;
  final String imageUrl;
  final String style;

  const TattooModel({
    required this.id,
    required this.artistEmail,
    required this.artistName,
    required this.imageUrl,
    required this.style,
  });

  factory TattooModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TattooModel(
      id: id, 
      artistEmail: data['artistEmail'] ?? '',
      artistName: data['artistName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      style: data['style'] ?? '',
    );
  }
}