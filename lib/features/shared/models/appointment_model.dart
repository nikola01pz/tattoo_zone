import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String artistId;
  final String clientId;
  final String clientName;
  final String clientImageUrl;
  final DateTime date;
  final int durationMinutes;
  final String style;
  final String description;
  final double price;
  final String status;
  final DateTime createdAt;

  const AppointmentModel({
    required this.id,
    required this.artistId,
    required this.clientId,
    required this.clientName,
    required this.clientImageUrl,
    required this.date,
    required this.durationMinutes,
    required this.style,
    required this.description,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  factory AppointmentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AppointmentModel(
      id: id,
      artistId: data['artistId'] ?? '',
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      clientImageUrl: data['clientImageUrl'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      durationMinutes: (data['durationMinutes'] ?? 0).toInt(),
      style: data['style'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'artistId': artistId,
      'clientId': clientId,
      'clientName': clientName,
      'clientImageUrl': clientImageUrl,
      'date': Timestamp.fromDate(date),
      'durationMinutes': durationMinutes,
      'style': style,
      'description': description,
      'price': price,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppointmentModel copyWith({
    String? status,
    double? price,
  }) {
    return AppointmentModel(
      id: id,
      artistId: artistId,
      clientId: clientId,
      clientName: clientName,
      clientImageUrl: clientImageUrl,
      date: date,
      durationMinutes: durationMinutes,
      style: style,
      description: description,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}