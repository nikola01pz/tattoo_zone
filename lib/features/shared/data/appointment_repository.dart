import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tattoo_zona/features/shared/models/appointment_model.dart';

class AppointmentRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  double _readPrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<List<AppointmentModel>> getArtistAppointments() async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('artistId', isEqualTo: _uid)
        .orderBy('date')
        .get();

    return snapshot.docs
        .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<AppointmentModel>> getPendingRequests() async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('artistId', isEqualTo: _uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('date')
        .get();

    return snapshot.docs
        .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('artistId', isEqualTo: _uid)
        .where('status', isEqualTo: 'confirmed')
        .where('date', isGreaterThan: Timestamp.now())
        .orderBy('date')
        .get();

    return snapshot.docs
        .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateStatus(String appointmentId, String status) async {
    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': status});
  }

  Future<void> addAppointment(AppointmentModel appointment) async {
    await _firestore.collection('appointments').add(appointment.toMap());
  }

  Future<double> getTotalEarnings() async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('artistId', isEqualTo: _uid)
        .where('status', isEqualTo: 'confirmed')
        .get();

    return snapshot.docs.fold<double>(0.0, (total, doc) {
      final price = _readPrice(doc.data()['price']);
      return total + price;
    });
  }

  Future<double> getMonthlyEarnings() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    final snapshot = await _firestore
        .collection('appointments')
        .where('artistId', isEqualTo: _uid)
        .where('status', isEqualTo: 'confirmed')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThan: Timestamp.fromDate(endOfMonth))
        .get();

    return snapshot.docs.fold<double>(0.0, (total, doc) {
      final price = _readPrice(doc.data()['price']);
      return total + price;
    });
  }

  Future<double> getWeeklyEarnings() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final end = start.add(const Duration(days: 7));

    final snapshot = await _firestore
        .collection('appointments')
        .where('artistId', isEqualTo: _uid)
        .where('status', isEqualTo: 'confirmed')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    return snapshot.docs.fold<double>(0.0, (total, doc) {
      final price = _readPrice(doc.data()['price']);
      return total + price;
    });
  }
}