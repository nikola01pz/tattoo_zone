import 'package:tattoo_zona/features/shared/models/appointment_model.dart';

abstract class AppointmentEvent {
  const AppointmentEvent();
}

class LoadAppointments extends AppointmentEvent {
  const LoadAppointments();
}

class UpdateAppointmentStatus extends AppointmentEvent {
  final String appointmentId;
  final String status;
  const UpdateAppointmentStatus({
    required this.appointmentId,
    required this.status,
  });
}

class AddAppointment extends AppointmentEvent {
  final AppointmentModel appointment;
  const AddAppointment(this.appointment);
}