import 'package:tattoo_zona/features/shared/models/appointment_model.dart';

abstract class AppointmentState {
  const AppointmentState();
}

class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

class AppointmentLoading extends AppointmentState {
  const AppointmentLoading();
}

class AppointmentLoaded extends AppointmentState {
  final List<AppointmentModel> pending;
  final List<AppointmentModel> upcoming;
  final List<AppointmentModel> all;
  final double totalEarnings;
  final double monthlyEarnings;
  final double weeklyEarnings;

  const AppointmentLoaded({
    required this.pending,
    required this.upcoming,
    required this.all,
    this.totalEarnings = 0,
    this.monthlyEarnings = 0,
    this.weeklyEarnings = 0,
  });
}

class AppointmentError extends AppointmentState {
  final String message;
  const AppointmentError(this.message);
}